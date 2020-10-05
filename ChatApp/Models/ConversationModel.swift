//
//  ConversationModel.swift
//  ChatApp
//
//  Created by sarath kumar on 01/10/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
