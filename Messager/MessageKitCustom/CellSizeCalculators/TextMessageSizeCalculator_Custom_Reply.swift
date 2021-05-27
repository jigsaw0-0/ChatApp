//
//  TextMessageSizeCalculator_Custom_Reply.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import Foundation
import UIKit
import MessageKit

open class TextMessageSizeCalculator_Custom_Reply: TextMessageSizeCalculator_Custom {
    
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        var size = super.messageContainerSize(for: message)
        size.height = size.height + kREPLYVIEWHEIGHT
        return size
        
    }
    
    
}
