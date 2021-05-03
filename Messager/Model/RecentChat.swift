//
//  RecentChat.swift
//  Messager
//
//  Created by David Kababyan on 24/08/2020.
//

import Foundation
import FirebaseFirestoreSwift

class RecentChat: Codable {
    
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
    
    init(id: String, chatRoomId: String, senderId: String, senderName: String, receiverId: String, receiverName: String, date: Date, memberIds: [String], lastMessage: String, unreadCounter: Int, avatarLink: String) {
        
        self.id = id
        self.chatRoomId = chatRoomId
        self.senderId = senderId
        self.senderName = senderName
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.date = date
        self.memberIds = memberIds
        self.lastMessage = lastMessage
        self.unreadCounter = unreadCounter
        self.avatarLink = avatarLink
        
        
    }
}
