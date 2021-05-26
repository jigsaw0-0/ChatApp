//
//  MediaMessageSizeCalculator_Custom.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import Foundation
import UIKit
import MessageKit

open class MediaMessageSizeCalculator_Custom: MediaMessageSizeCalculator {
    
    
//    open override func messageContainerSize(for message: MessageType) -> CGSize {
//        var size = super.messageContainerSize(for: message)
//        size.height = size.height + 100
//        return size
//        
//    }
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        
        var size = super.messageContainerSize(for: message)
        size.height += kREPLYVIEWHEIGHT
        return size
    
    }
    
    
}
