//
//  FirebaseRecentListener.swift
//  Messager
//
//  Created by David Kababyan on 24/08/2020.
//

import Foundation
import Firebase
import RxSwift
import RealmSwift

class XMPPRecentListener {
    var notificationToken: NotificationToken?

    static let shared = XMPPRecentListener()
    var allLocalMessages: Results<LocalMessage>!
    let realm = try! Realm()

    private init() {}
    
    
    
    
    func pollForRecentChats(completion : @escaping (_ allRecents :[RecentChat]) -> Void) {
        
        allLocalMessages = realm.objects(LocalMessage.self).sorted(byKeyPath: kDATE, ascending: false)
        
        
        notificationToken = allLocalMessages.observe { (change : RealmCollectionChange) in
            
           // let localElements = allLocalMessages.sorted(byKeyPath: kDATE, ascending: true).elements
            print("\nSomething changes in Realm Collection - Recent - Count \(self.allLocalMessages.count)")
            let distinctValues = self.allLocalMessages.distinct(by: [kCHATROOMID])
            var recentChats = [RecentChat]()
            for value in distinctValues {
                
                
                recentChats.append(RecentChat.init(id: value.id, chatRoomId: value.chatRoomId, senderId: value.senderId, senderName: value.senderName, receiverId: value.senderId, receiverName: "ReceiverName", date: value.date, memberIds: [], lastMessage: value.message, unreadCounter: 0, avatarLink: ""))
            }
            recentChats = recentChats.reversed()
            completion(recentChats)
            // let recentChats = [RecentChat]()
            
        }
        
        
        
        
        
    }
    
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) ->Void) {
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { (querySnapshot, error) in
            
            var recentChats: [RecentChat] = []
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent chats")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
        }
    }
    
    func resetRecentCounter(chatRoomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        
        var tempRecent = recent
        
        if tempRecent.senderId != User.currentId {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
    }
    
    func clearUnreadCounter(recent: RecentChat) {
        
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent)
    }
    
    func saveRecent(_ recent: RecentChat) {
        
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print("Error saving recent chat ", error.localizedDescription)
        }
    }
    
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
    
}
