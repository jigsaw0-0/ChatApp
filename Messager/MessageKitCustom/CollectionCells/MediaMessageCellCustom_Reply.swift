//
//  MediaMessageCellCustom_Reply.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import UIKit
import Foundation
import MessageKit

open class MediaMessageCellCustom_Reply : MediaMessageCellCustom {
    
    
    open var replyView = UIView()
    open var replyLabel = MessageLabel()
    open var replySenderName = UILabel()
    open var replyRightImageView = UIImageView()
    open var leftColorView = UIView()
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
    }

    
    func configureReply(with message: MKMessage, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView)  {
        if message.reply {
            replySenderName.text = "Dummy Name"
            // replySenderName.backgroundColor = UIColor.red
            print("Configuring Reply texy")
            replySenderName.textColor = UIColor.replyBubbleColors()[2]
            replySenderName.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            leftColorView.backgroundColor = UIColor.replyBubbleColors()[2]
            
            replyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            replyLabel.textColor = UIColor.replyLabelColor()
            
            if message.previousMsgType == "image" || message.previousMsgType == "video" {
                replyLabel.text = message.previousMsgType == "image" ? "Photo" : "Video"
                if let imgURL = URL.init(string: message.previousBody) {
                    replyRightImageView.sd_setImage(with: imgURL, placeholderImage: nil, options: .progressiveLoad, completed: nil)
                }
            }else{
                replyRightImageView.image = nil
                replyLabel.text = message.previousBody
            }
            
        }
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
          
            replyView.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: nil, right:  messageContainerView.rightAnchor, centerY: nil, centerX: nil, topConstant: 6, leftConstant: 6, bottomConstant: 6, rightConstant: 12, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: kREPLYVIEWHEIGHT - 12)
            
            
            leftColorView.addConstraints(replyView.topAnchor, left: replyView.leftAnchor, bottom: replyView.bottomAnchor, right: nil, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 3, heightConstant: 0)
        
            
            replySenderName.addConstraints(replyView.topAnchor, left: leftColorView.rightAnchor, bottom: nil, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 80, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 30)
            
            replyLabel.addConstraints(replySenderName.bottomAnchor, left: leftColorView.rightAnchor, bottom: nil, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 80, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 30)
            
            replyRightImageView.addConstraints(replyView.topAnchor, left: nil, bottom: replyView.bottomAnchor, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 70, heightConstant: 0)
            
            
        }
    }

    open override func setupSubviews(){
        super.setupSubviews()
        
        messageContainerView.addSubview(replyView)
        replyView.addSubview(replySenderName)
        replyView.addSubview(replyLabel)
        replyView.addSubview(replyRightImageView)
        replyView.addSubview(leftColorView)
        

        replyView.backgroundColor = UIColor.MKOutgoingBubbleReply
        replyView.layer.cornerRadius = 5
        replyView.layer.masksToBounds = true

    }
    
    open override func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        super.layoutMessageContainerView(with: attributes)
        var frame = messageContainerView.frame
        
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            frame.origin.x = 0
        case .cellTrailing:
            frame.origin.x = attributes.frame.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        
        messageContainerView.frame = frame

        
    }
    
    
    
    
    open override func layoutAvatarView(with attributes: MessagesCollectionViewLayoutAttributes) {
       // var origin: CGPoint = .zero
//        let padding = attributes.avatarLeadingTrailingPadding
//
//        switch attributes.avatarPosition.horizontal {
//        case .cellLeading:
//            origin.x = padding
//        case .cellTrailing:
//            origin.x = attributes.frame.width - attributes.avatarSize.width - padding
//        case .natural:
//            fatalError(MessageKitError.avatarPositionUnresolved)
//        }
//
//        switch attributes.avatarPosition.vertical {
//        case .messageLabelTop:
//            origin.y = messageTopLabel.frame.minY
//        case .messageTop: // Needs messageContainerView frame to be set
//            origin.y = messageContainerView.frame.minY
//        case .messageBottom: // Needs messageContainerView frame to be set
//            origin.y = messageContainerView.frame.maxY - attributes.avatarSize.height
//        case .messageCenter: // Needs messageContainerView frame to be set
//            origin.y = messageContainerView.frame.midY - (attributes.avatarSize.height/2)
//        case .cellBottom:
//            origin.y = attributes.frame.height - attributes.avatarSize.height
//        default:
//            break
//        }

        avatarView.frame = CGRect(origin: .zero, size: .zero)
    }
    
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    open override func setupConstraints() {

        imageView.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, right: messageContainerView.rightAnchor, centerY: nil, centerX: nil, topConstant: kREPLYVIEWHEIGHT, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 0)
        imageView.clipsToBounds = true
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
    }
    
}
