//
//  AppDelegate.swift
//  ChatApp
//
//  Created by sarath kumar on 22/09/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {

    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
    
    func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          print("failed to sign in with google: \(error)")
          return
        }
        
        guard let user = user else {
            return
        }
        
        guard let email = user.profile.email,
            let firstName = user.profile.givenName,
            let lastName = user.profile.familyName else {
                return
        }
        
        DatabaseManager.shared.userExists(with: email) { (exists) in
            if !exists {
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
            }
        }

        guard let authentication = user.authentication else {
            print("Missing auth object of the google user!")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        //Firebase Sign in
        Auth.auth().signIn(with: credential) { (authResult, error) in
            guard authResult != nil, error == nil else {
                print("Failed to login with google credential!")
                return
            }
            print("SuccessFully signedIn with google")
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
    
}



