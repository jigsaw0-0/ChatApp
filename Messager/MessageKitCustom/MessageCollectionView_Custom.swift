//
//  MessageCollectionView_Custom.swift
//  Messager
//
//  Created by Sriram S on 25/05/21.
//

import Foundation
import UIKit
import MessageKit

open class MessagesCollectionView_Custom: MessagesCollectionView {
    
    open var messagesCollectionViewFlowLayout_Custom: MessagesCollectionViewFlowLayout_Custom {
        guard let layout = collectionViewLayout as? MessagesCollectionViewFlowLayout_Custom else {
            fatalError(MessageKitError.layoutUsedOnForeignType)
        }
        return layout 
    }

}
