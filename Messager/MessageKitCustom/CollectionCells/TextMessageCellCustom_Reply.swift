//
//  TextMessageCellCustom_Reply.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import UIKit
import Foundation
import MessageKit

open class TextMessageCellCustom_Reply : TextMessageCellCustom {
    

    
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
            replyLabel.text = message.previousBody
            
            
        }
        
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.frame = CGRect(x: 0, y: kREPLYVIEWHEIGHT, width: messageContainerView.bounds.width, height: messageContainerView.bounds.height - kREPLYVIEWHEIGHT)
        
            replyView.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: nil, right:  messageContainerView.rightAnchor, centerY: nil, centerX: nil, topConstant: 7, leftConstant: attributes.messageLabelInsets.left - 4, bottomConstant: 7, rightConstant: attributes.messageLabelInsets.right - 6, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: kREPLYVIEWHEIGHT - 14)
            
            
            leftColorView.addConstraints(replyView.topAnchor, left: replyView.leftAnchor, bottom: replyView.bottomAnchor, right: nil, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 4, heightConstant: 0)
        
            
            replySenderName.addConstraints(replyView.topAnchor, left: leftColorView.rightAnchor, bottom: nil, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 80, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 30)
            
            replyLabel.addConstraints(replySenderName.bottomAnchor, left: leftColorView.rightAnchor, bottom: nil, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 80, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 30)
            
            
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
        
        
        

        setupReplyConstraints()
    }
    
    open func setupReplyConstraints(){
        
       
        
        
        
        
    }
}
