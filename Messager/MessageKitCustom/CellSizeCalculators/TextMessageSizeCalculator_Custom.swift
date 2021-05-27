//
//  TextMessageSizeCalculator_Custom.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import Foundation
import UIKit
import MessageKit

open class TextMessageSizeCalculator_Custom: TextMessageSizeCalculator {
    
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        var size = super.messageContainerSize(for: message)
        return size
        
    }
    
    
    
    
    
    
}
