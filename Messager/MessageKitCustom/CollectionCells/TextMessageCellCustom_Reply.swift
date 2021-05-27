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
    

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
    }

    
    func configureReply(with message: MKMessage, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView)  {
        if message.reply {
            
            print("Configuring Reply texy")
            
        }
        
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.frame = CGRect(x: 0, y: kREPLYVIEWHEIGHT, width: messageContainerView.bounds.width, height: messageContainerView.bounds.height - kREPLYVIEWHEIGHT)
        }
    }
    
    
}
