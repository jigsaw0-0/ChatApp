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
    
    
    func configureReply(with message: MKMessage, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView)  {
        if message.reply {
            
            print("Configuring Reply media")
            
        }
        
    }
    
    open override func setupConstraints() {

        imageView.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, right: messageContainerView.rightAnchor, centerY: nil, centerX: nil, topConstant: kREPLYVIEWHEIGHT, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 0)
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
    }
    
}
