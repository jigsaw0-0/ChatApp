//
//  TextMessageCellCustom.swift
//  Messager
//
//  Created by Sriram S on 22/05/21.
//

import UIKit
import Foundation
import MessageKit

open class TextMessageCellCustom : TextMessageCell {
    
    
    
//    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        super.apply(layoutAttributes)
//        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
//            messageLabel.frame = CGRect(x: 0, y: kREPLYVIEWHEIGHT, width: messageContainerView.bounds.width, height: messageContainerView.bounds.height - kREPLYVIEWHEIGHT)
//        }
//    }
    
    
    
    
    
    
    
    
    //MARK:- Layouting - Avatar Removed
    
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
    
    
    
}
