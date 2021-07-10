//
//  FirebaseMessageListener.swift
//  Messager
//
//  Created by David Kababyan on 31/08/2020.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import XMPPFramework
import RxSwift
import KissXML


@objc protocol XMPPMessageSubscribeListener: AnyObject {
    
    func messageReceivedFromMam(message: XMPPMessage)
  
}




class XMPPMessageListener {
    var mamWorkers : Dictionary<String, XMPPMamWorker> = [:]
    static let shared = XMPPMessageListener()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<LocalMessage>()
    var subscription : Disposable?
    let disposeBagSubscription = DisposeBag()
    
    private init() { }
    private var listeners: [XMPPMessageSubscribeListener] = []
       
       func addListener(_ listener: XMPPMessageSubscribeListener) {
          // if listeners.contains(listener) { return }//or compare an id
          // listeners.append(listener)
       }
    
    //MARK:- MAM Handlers
    
    func createWorker(with queryId: String) {
        
        let worker = XMPPMamWorker.init(queryId)
        self.mamWorkers[queryId] = worker
        print("XMPPTest -> Worker craeted")

    }
    
    func finishWorker(with queryid : String) {
        
        if let worker = mamWorkers[queryid] {
            print("Trying to finish worder with qId ->\(queryid)")
            worker.finish()
        }
    }
    
    //MARK:- Stream Message Handlers
    
    
    func handleStreamMessage(_ message : XMPPMessage){
        
        let localTuple = convertXMPPMessageToLocalMessage(message)
        if let localMessage = localTuple.0 {
            localMessage.queryId = localTuple.1
            print("XMPPTest -> message sent to worder")

            self.subject.onNext(localMessage)
        }
        
    }
    
    func listenForSingleMessages(){
        
        subscription = self.subject.filter{ $0.queryId == "" }.subscribe { (event) in
            
            if let element = event.element {
                RealmManager.shared.saveToRealm(element)
            }

            
            
        }
        
        self.subscription?.disposed(by: self.disposeBagSubscription)

        
    }
    
    
    
    func convertXMPPMessageToLocalMessage(_ xmppMessage : XMPPMessage) -> (LocalMessage?, String ){
        
        let message = LocalMessage()
        if let mamResult = xmppMessage.mamResult {
            let queryId = mamResult.attribute(forName: "queryid")?.stringValue ?? ""
            if let forwardedMessage = mamResult.forwardedMessage {
               // print("\nForwarded message body -> \(forwardedMessage.body ?? "No message!")")
                
                message.queryId = queryId
                if let elementIdForMessage = forwardedMessage.elementID {
                 //   print("Message Element ID - \(elementIdForMessage)")
                    
                }
                let previousElements = forwardedMessage.elements(forName: "previousdata")
                for ob in previousElements {
                    
                    if let body = ob.attributeStringValue(forName: "body") {
                        message.previousBody = body
                        print("Replied msg --> body")
                    }
                    if let msgid = ob.attributeStringValue(forName: "msgid") {
                        message.previousMsgId = msgid
                    }
                    if let msgtype = ob.attributeStringValue(forName: "msgtype") {
                        message.previousMsgType = msgtype
                    }
                    break
                    
                }
                
                
                let stanzaIds = forwardedMessage.stanzaIds
                //print("Message Stanza ID - \(stanzaIds)")
                if stanzaIds.count > 0 {
                    message.id = stanzaIds.first?.value ?? ""
                }
                message.senderId = forwardedMessage.fromStr ?? ""
                let xElement = forwardedMessage.elements(forName: "x")
                if xElement.count > 0 {
                    
                    let xElementItems = xElement[0].elements(forName: "item")
                    for item in xElementItems {
                        if var senderJID = item.attributeStringValue(forName: "jid") {
                            if let slashRange = senderJID.range(of: "/") {
                                senderJID.removeSubrange(slashRange.lowerBound..<senderJID.endIndex)
                            }
                            message.senderId = senderJID
                        }
                        break
                    }
                }
                
                message.senderName = "Dummy"
                
                var someStr = xmppMessage.fromStr ?? ""
                if let slashRange = someStr.range(of: "/") {
                    someStr.removeSubrange(slashRange.lowerBound..<someStr.endIndex)
                }

                message.chatRoomId = chatRoomIdFrom(user1Id: someStr ?? "", user2Id: xmppMessage.toStr ?? "")
                if let localDate = mamResult.forwardedStanzaDelayedDeliveryDate {
                    message.date = localDate
                 //   print("\n(localDate ->\(localDate)")
                }
                
                let msgAttrArr = forwardedMessage.elements(forName: "msgattr")
                if msgAttrArr.count > 0 {
                    if let type = msgAttrArr[0].attributeStringValue(forName: "type") {
                        
                        if let body = forwardedMessage.body {
                          //  print("\nType ->\(type) , body -> \(body)")
                            switch type {
                            case "text":
                                message.type = kTEXT
                                message.message = body
                            case "image":
                                message.type = kPHOTO
                                message.pictureUrl = body
                            case "audio":
                                message.type = kAUDIO
                                message.audioUrl = body
                            case "video":
                                message.type = kVIDEO
                                message.videoUrl = body
                                print("Got video body ->\(body)")
                            case "document":
                                message.type = kDOCUMENT
                                message.documentUrl = body
                            default:
                                message.type = kTEXT
                                message.message = body
                            }
                        }
                        
                    }
                }
                return (message, queryId)
            }
        }else if xmppMessage.isMessageWithBody {
           
            
            // print("\nForwarded message body -> \(forwardedMessage.body ?? "No message!")")
            let forwardedMessage = xmppMessage
             message.queryId = ""
             if let elementIdForMessage = forwardedMessage.elementID {
              //   print("Message Element ID - \(elementIdForMessage)")
                 
             }
             let stanzaIds = forwardedMessage.stanzaIds
             //print("Message Stanza ID - \(stanzaIds)")
             if stanzaIds.count > 0 {
                 message.id = stanzaIds.first?.value ?? ""
             }
             message.senderId = forwardedMessage.fromStr ?? ""
            let xElement = forwardedMessage.elements(forName: "x")
            if xElement.count > 0 {
                
                let xElementItems = xElement[0].elements(forName: "item")
                for item in xElementItems {
                    if var senderJID = item.attributeStringValue(forName: "jid") {
                        if let slashRange = senderJID.range(of: "/") {
                            senderJID.removeSubrange(slashRange.lowerBound..<senderJID.endIndex)
                        }
                        message.senderId = senderJID
                    }
                    break
                }
            }
             message.senderName = "Dummy"
            
            let previousElements = forwardedMessage.elements(forName: "previousdata")
            for ob in previousElements {
                
                if let body = ob.attributeStringValue(forName: "body") {
                    message.previousBody = body
                    print("Replied msg --> body")
                }
                if let msgid = ob.attributeStringValue(forName: "msgid") {
                    message.previousMsgId = msgid
                }
                if let msgtype = ob.attributeStringValue(forName: "msgtype") {
                    message.previousMsgType = msgtype
                }
                break
                
            }

            var someStr = xmppMessage.fromStr ?? ""
            if let slashRange = someStr.range(of: "/") {
                someStr.removeSubrange(slashRange.lowerBound..<someStr.endIndex)
            }
            
             message.chatRoomId = chatRoomIdFrom(user1Id: someStr ?? "", user2Id: xmppMessage.toStr ?? "")
//             if let localDate = mamResult.forwardedStanzaDelayedDeliveryDate {
//                 message.date = localDate
//              //   print("\n(localDate ->\(localDate)")
//             }
            message.date = Date()
             let msgAttrArr = forwardedMessage.elements(forName: "msgattr")
             if msgAttrArr.count > 0 {
                 if let type = msgAttrArr[0].attributeStringValue(forName: "type") {
                     
                     if let body = forwardedMessage.body {
                       //  print("\nType ->\(type) , body -> \(body)")
                         switch type {
                         case "text":
                             message.type = kTEXT
                             message.message = body
                         case "image":
                             message.type = kPHOTO
                             message.pictureUrl = body
                         case "audio":
                             message.type = kAUDIO
                             message.audioUrl = body
                         case "video":
                             message.type = kVIDEO
                             message.videoUrl = body
                             print("Got video body ->\(body)")
                         case "document":
                             message.type = kDOCUMENT
                             message.documentUrl = body
                             
                         default:
                             message.type = kTEXT
                             message.message = body
                         }
                     }
                     
                 }
             }
             return (message, "")
         }
        
        
        
        //        message.id = UUID().uuidString
        //        message.chatRoomId = chatId
        //        message.senderId = currentUser.id
        //        message.senderName = currentUser.username
        //        message.senderinitials = String(currentUser.username.first!)
        //        message.date = Date()
        //        message.status = kSENT
        
        
        
        
        return (nil, "")
        
        
    }
    
    
    
    
    
    
    
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                
                if change.type == .added {
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject {
                            
                            if message.senderId != User.currentId {
                                RealmManager.shared.saveToRealm(message)
                            }
                        } else {
                            print("Document doesnt exist")
                        }
                        
                    case .failure(let error):
                        print("Error decoding local message: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        
        updatedChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ (querySnapshot, error) in
            
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject {
                            completion(message)
                        } else {
                            print("Document does not exist chat")
                        }
                        
                        
                    case .failure(let error):
                        print("Error decoding local message: \(error)")
                    }
                }
            }
        })
    }
    
    
    
    
    func checkForOldChats(_ documentId: String, collectionId: String) {
        
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for old chats")
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: { $0.date < $1.date })
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
        }
    }
    
    //MARK: - Add, Update, Delete

    func sendMessageXMPP(_ message: LocalMessage) {
        
        var messageBody = message.message
        let receiverJID = XMPPJID(string: message.chatRoomId)
        let msg = XMPPMessage(type: "groupchat", to: receiverJID)
        //msg.addActiveChatState()
        let msgAttr = DDXMLElement.init(name: "msgattr")
        var msgAttrStr = "text"
        switch message.type {
        case "image","photo":
            msgAttrStr = "image"
            messageBody = message.pictureUrl
            
        case "video":
            msgAttrStr = "video"
            messageBody = message.videoUrl

        case "document","pdf":
            msgAttrStr = "document"
            messageBody = message.pictureUrl
        case "audio":
            msgAttrStr = "audio"
            messageBody = message.audioUrl
        default:
            msgAttrStr = "text"
            
        }
        msg.addBody(messageBody)
        msgAttr.addAttribute(withName: "type", stringValue: msgAttrStr)
        if message.reply {
            msgAttr.addAttribute(withName: "reply", stringValue: "yes")
            let previousdata = DDXMLElement.init(name: "previousdata")
            previousdata.addAttribute(withName: "body", stringValue: message.previousBody)
            previousdata.addAttribute(withName: "msgid", stringValue: message.previousMsgId)
            previousdata.addAttribute(withName: "msgtype", stringValue: message.previousMsgType)
            msg.addChild(previousdata)
        }
        
        msg.addChild(msgAttr)
        msg.addActiveChatState()
        
        
        
        
        
        XMPPManager.shared.sendMessage(msg)
        
        
        
    }
    
    
    func addMessage(_ message: LocalMessage, memberId: String) {
        // actual sending
        
        sendMessageXMPP(message)
//        do {
//            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
//        }
//        catch {
//            print("error saving message ", error.localizedDescription)
//        }
    }
    
    func addChannelMessage(_ message: LocalMessage, channel: Channel) {
        
        do {
            let _ = try FirebaseReference(.Messages).document(channel.id).collection(channel.id).document(message.id).setData(from: message)
        }
        catch {
            print("error saving message ", error.localizedDescription)
        }
    }
    
    
    //MARK: - UpdateMessageStatus
    func updateMessageInFireStore(_ message: LocalMessage, memberIds: [String]) {
        
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]
        
        for userId in memberIds {
            FirebaseReference(.Messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }
    
    
    func removeListeners() {
       // self.newChatListener.remove()
        
        if self.updatedChatListener != nil {
            self.updatedChatListener.remove()
        }
    }
}
