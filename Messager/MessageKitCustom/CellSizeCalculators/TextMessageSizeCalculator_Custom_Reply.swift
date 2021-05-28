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
        
        size.width = max(size.width, 220)
        return size
        
    }
    
//    open func getTextLabelWidthForString(_ message : MKMessage) -> CGSize {
//        
//        var maxWidth = messageContainerMaxWidth(for: message)
//        if message.previousMsgType == "text" {
//        attributedText = NSAttributedString(string: message.previousBody, attributes: [.font: messageLabelFont])
//        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)
//        }else{
//            maxWidth = 210
//        }
//        
//        
//        
//    }
    
    
    
}
