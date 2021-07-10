//
//  DocumentMessageSizeCalculator_Custom_Reply.swift
//  Messager
//
//  Created by Sriram S on 10/07/21.
//

import Foundation
import UIKit
import MessageKit

open class DocumentMessageSizeCalculator_Custom_Reply: DocumentMessageSizeCalculator_Custom {
    
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
