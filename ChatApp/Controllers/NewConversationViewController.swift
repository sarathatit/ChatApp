//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by sarath kumar on 22/09/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    public var completion: ((SearchResults) -> Void)?
    
    private var users = [[String: String]]()
    private var results = [SearchResults]()
    private var hasfetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "search for new chat.."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "Cell")
        return table
    }()
    
    private let noSearchResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No search results"
        label.textAlignment = .center
        label.textColor = .red
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(noSearchResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.searchBar.delegate = self
        
        self.view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(cancelBarButtonAction))
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = view.bounds
        self.noSearchResultsLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 400)
    }
    
    // MARK: - Action Methods
    
    @objc func cancelBarButtonAction() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.isEmpty, !text.replacingOccurrences(of: " ", with: "").isEmpty  else {
            return
        }
        
        self.results.removeAll()
        
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        
        if hasfetched {
            self.filterUser(with: query)
        } else {
            DatabaseManager.shared.getAllUsers { [weak self] (result) in
                switch result {
                case .success(let userCollection):
                    self?.users = userCollection
                    self?.hasfetched = true
                    self?.filterUser(with: query)
                case .failure(let error):
                    print("error to fetch the data: \(error)")
                }
            }
        }
    }
    
    func filterUser(with term: String) {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasfetched else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(with: currentUserEmail)

        self.spinner.dismiss()

        let results: [SearchResults] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }

            guard let name = $0["name"]?.lowercased() else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        }).compactMap({

            guard let email = $0["email"],
                let name = $0["name"] else {
                return nil
            }

            return SearchResults(name: name, email: email)
        })

        self.results = results
        
        updateUI()
    }
    
    
    func updateUI() {
        if results.isEmpty {
            self.noSearchResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noSearchResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
