//
//  FirebaseTypingListener.swift
//  Messager
//
//  Created by David Kababyan on 07/09/2020.
//

import Foundation
import Firebase
import XMPPFramework
import RxSwift


class XMPPTypingListener {
    
    static let shared = XMPPTypingListener()
    
    var typingListener: ListenerRegistration!
    
    let composeSubject = PublishSubject<String>()
    var subscription : Disposable?
    let disposeBagSubscription = DisposeBag()
    
    
    
    private init() { }
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        
        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                for data in snapshot.data()! {
                    
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirebaseReference(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        
        FirebaseReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])

    }
    
    func removeTypingListener() {
      //  self.typingListener.remove()
    }
    
    func feedComposeMessage(message : XMPPMessage) {
        print("Compose Message ->\(message.fromStr ?? "Nothing")")
        composeSubject.onNext(message.fromStr ?? "Nothing")
        
    }
    
    
}
