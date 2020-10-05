//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by sarath kumar on 22/09/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .regular)) 
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Register"
        self.view.backgroundColor = .white
        registerButton.addTarget(self, action: #selector(registerButtonAction), for: .touchUpInside)
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Add subview
        self.view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(firstNameTextField)
        scrollView.addSubview(lastNameTextField)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(registerButton)
        
        scrollView.isUserInteractionEnabled = true
        logoImageView.isUserInteractionEnabled = true
        let gesterRecognizer = UITapGestureRecognizer(target: self, action: #selector(logoImageViewAction))
        logoImageView.addGestureRecognizer(gesterRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        logoImageView.frame = CGRect(x: (scrollView.width - size)/2,
                                     y: 20,
                                     width: size,
                                     height: size)
        logoImageView.layer.cornerRadius = logoImageView.width/2.0
        
        firstNameTextField.frame = CGRect(x: 30,
                                      y: logoImageView.bottom+20,
                                      width: scrollView.width-60,
                                      height: 52)
        lastNameTextField.frame = CGRect(x: 30,
                                      y: firstNameTextField.bottom+10,
                                      width: scrollView.width-60,
                                      height: 52)
        emailTextField.frame = CGRect(x: 30,
                                      y: lastNameTextField.bottom+10,
                                      width: scrollView.width-60,
                                      height: 52)
        passwordTextField.frame = CGRect(x: 30,
                                         y: emailTextField.bottom+10,
                                         width: scrollView.width-60,
                                         height: 52)
        registerButton.frame = CGRect(x: 30,
                                   y: passwordTextField.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
        
    }
    
    // MARK: - Action Methods
    
    @objc func logoImageViewAction() {
         logoImagePickerAction()
    }
    
    @objc func registerButtonAction() {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        guard let firstName = firstNameTextField.text, let lastname = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, !firstName.isEmpty, !lastname.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            self.showAlert(titleInput: "Warning..", messageInput: "Please enter the all the information to Register.")
            return
        }
        
        self.spinner.show(in: view, animated: true)
        
        // Firebase Resiteration
        DatabaseManager.shared.userExists(with: email) { [weak self] (exists) in
            guard let strongSelf = self else  {
                return 
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                self?.showAlert(titleInput: "Warning", messageInput: "User already exists")
                return
            }
            Auth.auth().createUser(withEmail: email, password: password) {  (authResult, error) in
                
                guard authResult != nil, error == nil else {
                    print("Error creating the user")
                    return
                }
                
                let chatUser = ChatAppUser(firstName: firstName, lastName: lastname, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        // upload the image
                        guard let image = strongSelf.logoImageView.image, let data = image.pngData() else {
                            return
                        }
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
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            self.registerButtonAction()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func logoImagePickerAction() {
        let alert = UIAlertController(title: "Choose", message: "How whould you like to choose?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.chooseImage()
        }))
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.takeImage()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func chooseImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func takeImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        logoImageView.image = info[.editedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
