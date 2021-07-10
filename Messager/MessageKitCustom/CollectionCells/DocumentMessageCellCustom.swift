//
//  DocumentMessageCellCustom.swift
//  Messager
//
//  Created by Sriram S on 10/07/21.
//

import UIKit
import Foundation
import MessageKit
import PDFKit

open class DocumentMessageCellCustom : MediaMessageCell {
    
    let curvedMainView = UIView()
    let pdfView = PDFView()
    let nameView = UIView()
    let pdfIcon = UIImageView()
    let nameLabel = UILabel()
    
    
    
    
    
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
    open override func setupSubviews(){
        super.setupSubviews()
        
        messageContainerView.addSubview(curvedMainView)
        curvedMainView.addSubview(pdfView)
        curvedMainView.addSubview(nameView)
        nameView.addSubview(pdfIcon)
        nameView.addSubview(nameLabel)

        curvedMainView.backgroundColor = UIColor.MKOutgoingBubbleReply
        curvedMainView.layer.cornerRadius = 5
        curvedMainView.layer.masksToBounds = true

    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            
            curvedMainView.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: nil, right: messageContainerView.rightAnchor, centerY: nil, centerX: nil, topConstant: 6, leftConstant: 12, bottomConstant: 0, rightConstant: 6, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 0)
            
            pdfView.addConstraints(curvedMainView.topAnchor, left: curvedMainView.leftAnchor, bottom: nil, right: curvedMainView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 100)
            
            
            nameView.addConstraints(pdfView.bottomAnchor, left: curvedMainView.leftAnchor, bottom: curvedMainView.bottomAnchor, right: curvedMainView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 40)
            
            pdfIcon.addConstraints(nil, left: nameView.leftAnchor, bottom: nil, right: nil, centerY: nameView.centerYAnchor, centerX: nil, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 14, heightConstant: 24)
        
        
            nameLabel.addConstraints(nameView.topAnchor, left: pdfIcon.rightAnchor, bottom: nameView.bottomAnchor, right: nameView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 0)
            
            nameView.backgroundColor = UIColor.blue
            pdfView.backgroundColor = UIColor.red
            pdfIcon.backgroundColor = UIColor.yellow
            nameLabel.backgroundColor = UIColor.orange
            
            
        }
        
    }





}
