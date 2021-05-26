//
//  MediaMessageCellCustom.swift
//  Messager
//
//  Created by Sriram S on 22/05/21.
//

import UIKit
import Foundation
import MessageKit

open class MediaMessageCellCustom : MediaMessageCell {
    
    
    open override func setupConstraints() {
       // imageView.fillSuperview()
        self.contentView.backgroundColor = UIColor.orange
        self.messageContainerView.backgroundColor = UIColor.blue
        imageView.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, right: messageContainerView.rightAnchor, centerY: nil, centerX: nil, topConstant: kREPLYVIEWHEIGHT, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 0)
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
    }
    
    
    
    
    
}
