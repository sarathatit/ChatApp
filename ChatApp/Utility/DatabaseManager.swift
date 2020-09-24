//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by sarath kumar on 23/09/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import Foundation
import Firebase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
   
}

// MARK: - Account Management

extension DatabaseManager {
    
    /// found user exists
    public func userExists(with email: String, completion: @escaping ((Bool)) -> Void) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Insert new user to database.
    public func insertUser(with user: ChatAppUser) {
           database.child(user.safeEmail).setValue([
               "first_name": user.firstName,
               "las_name" : user.lastName])
       }
    
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
