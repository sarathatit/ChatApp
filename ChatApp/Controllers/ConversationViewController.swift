//
//  ViewController.swift
//  ChatApp
//
//  Created by sarath kumar on 22/09/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class ConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversation = [Conversation]()
    
    private var loginObserver: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No Conversations"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeBarButtonAction))
        self.view.addSubview(tableView)
        self.view.addSubview(noConversationsLabel)
        setupTableView()
        startListeningForConversation()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForConversation()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuthentication()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10, y: (view.height - 100)/2, width: (view.width - 10), height: 100)
    }
    
    // MARK: - Custom Methods
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    func validateAuthentication() {
        if  Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: false, completion: nil)
        }
    }
    
    // MARK: - Data Load methods
    
    private func startListeningForConversation() {
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(with: email)
        
        print("Start conversation fetching...")
        
        DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self] (result) in
            switch result {
                
            case .success(let conversation):
                guard !conversation.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.tableView.isHidden = false
                self?.noConversationsLabel.isHidden = true
                self?.conversation = conversation
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to fetch the conversation: \(error)")
            }
        }
    }
    
    // MARK: - Action Methods
    
    @objc func composeBarButtonAction() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            print("\(result)")
            strongSelf.createNewConversation(result: result)
        }
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
    
    private func createNewConversation(result: SearchResults) {
        let name = result.name
        let email = DatabaseManager.safeEmail(with: result.email)
        
        // Check in the database for conversation is exists for user
        //if available use the conversation id
        // else create new
        
        DatabaseManager.shared.conversationExists(targetRecipientEmail: email) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, conversationId: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, conversationId: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension ConversationViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversation[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversation[indexPath.row]
        openConverssation(model)
    }
    
    func openConverssation(_ model: Conversation) {
        let vc = ChatViewController(with: "", conversationId: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

