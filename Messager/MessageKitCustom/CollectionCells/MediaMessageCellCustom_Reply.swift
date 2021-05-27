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
    
    
    
}
