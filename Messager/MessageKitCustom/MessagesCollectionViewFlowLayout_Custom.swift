//
//  MessagesCollectionViewFlowLayout_Custom.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import Foundation
import UIKit
import AVFoundation
import MessageKit

/// The layout object used by `MessagesCollectionView` to determine the size of all
/// framework provided `MessageCollectionViewCell` subclasses.
open class MessagesCollectionViewFlowLayout_Custom: MessagesCollectionViewFlowLayout {
    
    // MARK: - Cell Sizing

    lazy open var textMessageSizeCalculator_custom = TextMessageSizeCalculator_Custom(layout: self)
    lazy open var mediaMessageSizeCalculator_custom = MediaMessageSizeCalculator_Custom(layout: self)
    lazy open var locationMessageSizeCalculator_custom = LocationMessageSizeCalculator_Custom(layout: self)
    lazy open var audioMessageSizeCalculator_custom = AudioMessageSizeCalculator_Custom(layout: self)
    lazy open var contactMessageSizeCalculator_custom = ContactMessageSizeCalculator_Custom(layout: self)
    lazy open var linkPreviewMessageSizeCalculator_custom = LinkPreviewMessageSizeCalculator_Custom(layout: self)
    
    lazy open var textMessageSizeCalculator_custom_R = TextMessageSizeCalculator_Custom_Reply(layout: self)
    lazy open var mediaMessageSizeCalculator_custom_R = MediaMessageSizeCalculator_Custom_Reply(layout: self)
    lazy open var locationMessageSizeCalculator_custom_R = LocationMessageSizeCalculator_Custom_Reply(layout: self)
    lazy open var audioMessageSizeCalculator_custom_R = AudioMessageSizeCalculator_Custom_Reply(layout: self)
    lazy open var contactMessageSizeCalculator_custom_R = ContactMessageSizeCalculator_Custom_Reply(layout: self)
    lazy open var linkPreviewMessageSizeCalculator_custom_R = LinkPreviewMessageSizeCalculator_Custom_Reply(layout: self)
    
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var arr : [MessageSizeCalculator] = super.messageSizeCalculators()
        arr.append(textMessageSizeCalculator_custom)
        return arr
    }


    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        let isMessageReply = (message as! MKMessage).reply
        let cellSizeCalculator = super.cellSizeCalculatorForItem(at: indexPath)
        switch cellSizeCalculator {
        case is TextMessageSizeCalculator:
            return !isMessageReply ? textMessageSizeCalculator_custom : textMessageSizeCalculator_custom_R
        case is MediaMessageSizeCalculator:
            return !isMessageReply ? mediaMessageSizeCalculator_custom : mediaMessageSizeCalculator_custom_R
        case is LocationMessageSizeCalculator:
            return !isMessageReply ? locationMessageSizeCalculator_custom : locationMessageSizeCalculator_custom_R
        case is AudioMessageSizeCalculator:
            return !isMessageReply ? audioMessageSizeCalculator_custom : audioMessageSizeCalculator_custom_R
        case is ContactMessageSizeCalculator:
            return !isMessageReply ? contactMessageSizeCalculator_custom : contactMessageSizeCalculator_custom_R
        case is LinkPreviewMessageSizeCalculator:
            return !isMessageReply ? linkPreviewMessageSizeCalculator_custom : linkPreviewMessageSizeCalculator_custom_R
        
        default:
            return cellSizeCalculator
        }
        
        
        
    }


}
