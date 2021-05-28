//
//  LinkPreviewMessageSizeCalculator_Custom_Reply.swift.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import Foundation
import UIKit
import MessageKit

open class LinkPreviewMessageSizeCalculator_Custom_Reply: LinkPreviewMessageSizeCalculator_Custom {
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        var size = super.messageContainerSize(for: message)
        size.height = size.height + kREPLYVIEWHEIGHT
        
        size.width = max(size.width, 220)
        return size
        
    }
//    open override func messageContainerSize(for message: MessageType) -> CGSize {
//        var size = super.messageContainerSize(for: message)
//        size.height = size.height + 100
//        return size
//
//    }
    
    
}
