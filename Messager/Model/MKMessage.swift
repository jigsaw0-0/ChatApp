//
//  MKMessage.swift
//  Messager
//
//  Created by David Kababyan on 30/08/2020.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var prevMessageKind : MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitials: String
    
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?

    var status: String
    var readDate: Date
    
    var previousBody = ""
    var previousMsgId = ""
    var previousMsgType = ""
    var reply = false
    var documentUrl = ""
    var documentKind = false
    
    init(message: LocalMessage) {
        
        self.messageId = message.id
        
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
            
        case kPHOTO:
            
            let photoItem = PhotoMessage(path: message.pictureUrl)
            
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case kVIDEO:
            
            let videoItem = VideoMessage(url: URL.init(string: message.videoUrl))
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
            
        case kLOCATION:
            
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
            
        case kAUDIO:
            
            let audioItem = AudioMessage(duration: 2.0)
            
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
        
        case kDOCUMENT:
            let photoItem = PhotoMessage(path: "")
            self.kind = MessageKind.photo(photoItem)
            if message.documentUrl.count > 0 {
                self.documentKind = true
            }
            self.documentUrl = message.documentUrl
            
        default:
            self.kind = MessageKind.text(message.message)
            print("unknown message type")
        }
        
        self.senderInitials = message.senderinitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        
        // Reply Kind
        self.prevMessageKind = MessageKind.text("")
        
        switch message.previousMsgType {
        case kTEXT:
            self.prevMessageKind = MessageKind.text(message.previousBody)
            
        case kPHOTO:
            
            let photoItem = PhotoMessage(path: message.previousBody)
            
            self.prevMessageKind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case kVIDEO:
            
            let videoItem = VideoMessage(url: URL.init(string: message.previousBody))
            self.prevMessageKind = MessageKind.video(videoItem)
            self.videoItem = videoItem
            
        case kLOCATION:
            
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            
            self.prevMessageKind = MessageKind.location(locationItem)
            self.locationItem = locationItem
            
        case kAUDIO:
            
            let audioItem = AudioMessage(duration: 2.0)
            
            self.prevMessageKind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
        
        case kDOCUMENT:
            let photoItem = PhotoMessage(path: "")
            self.prevMessageKind = MessageKind.photo(photoItem)
            if message.documentUrl.count > 0 {
                self.documentKind = true
            }
            self.documentUrl = message.documentUrl
            
            
            
        default:
            self.prevMessageKind = MessageKind.text(message.previousBody)
            print("unknown message type")
        }
        
        
        
    }
}
