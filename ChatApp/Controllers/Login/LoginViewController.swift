//
//  LoginViewController.swift
//  ChatApp
//
//  Created by sarath kumar on 22/09/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    private let googleLoginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    private let spinner = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        self.title = "Log In"
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(registerAction))
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        facebookLoginButton.delegate = self
        
        // Add subview
        self.view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    deinit {
        if let obsever = loginObserver {
            NotificationCenter.default.removeObserver(obsever)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        logoImageView.frame = CGRect(x: (scrollView.width - size)/2,
                                     y: 20,
                                     width: size,
                                     height: size)
        emailTextField.frame = CGRect(x: 30,
                                      y: logoImageView.bottom+20,
                                      width: scrollView.width-60,
                                      height: 52)
        passwordTextField.frame = CGRect(x: 30,
                                      y: emailTextField.bottom+10,
                                      width: scrollView.width-60,
                                      height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordTextField.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
        facebookLoginButton.frame = CGRect(x: 30,
                                   y: loginButton.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
        googleLoginButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom+20,
                                         width: scrollView.width-60,
                                         height: 52)
    }

    // MARK: - Action Methods
    
    @objc func registerAction() {
        let registerVC = RegisterViewController()
        registerVC.title = "Create Account"
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc func loginButtonAction() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            self.showAlert(titleInput: "Warning..", messageInput: "Please enter the all the information to login.")
            return
        }
        
        self.spinner.show(in: view, animated: true)
        
        // Firebase Login
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard let result = authResult, error == nil else {
                print("Unable to login")
                return
            }
            
            let safeEmail = DatabaseManager.safeEmail(with: email)
            DatabaseManager.shared.getDataFor(path: safeEmail) { (result) in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                        let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("failed to get the user data: \(error)")
                }
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            
            let user = result.user
            print("Logged in \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            self.loginButtonAction()
        }
        return true
    }
}

// MARK:- FaceBook Login
extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to login with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":
                                                            "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _,result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make the facebook graph request")
                return
            }
            print("FaceBook result: \(result)")
             guard let firstName = result["first_name"] as? String,
                           let lastName = result["last_name"] as? String,
                           let email = result["email"] as? String,
                           let picture = result["picture"] as? [String: Any],
                           let data = picture["data"] as? [String: Any],
                           let pictureUrl = data["url"] as? String else {
                               print("Faield to get email and name from fb result")
                               return
                       }
            
            DatabaseManager.shared.userExists(with: email) { (exists) in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            guard  let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data,_,_ in
                                guard let data = data else {
                                    print("failed to get the data from facebook")
                                    return
                                }
                                // upload the image
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                }
                                }).resume()
                        }
                    })
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            //use that credential to auth the firebase
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential failed to login, MFA may be needed \(error)")
                    }
                    return
                }
                UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                UserDefaults.standard.set(email, forKey: "email")
                print("Login success from the facebook")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        })
    }
}
