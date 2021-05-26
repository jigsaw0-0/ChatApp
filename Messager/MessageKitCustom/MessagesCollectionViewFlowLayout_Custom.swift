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

    
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var arr : [MessageSizeCalculator] = super.messageSizeCalculators()
        arr.append(textMessageSizeCalculator_custom)
        return arr
    }


    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        
        let cellSizeCalculator = super.cellSizeCalculatorForItem(at: indexPath)
        switch cellSizeCalculator {
        case is TextMessageSizeCalculator:
            return textMessageSizeCalculator_custom
        case is MediaMessageSizeCalculator:
            return mediaMessageSizeCalculator_custom
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        default:
            return cellSizeCalculator
        }
        
        
        
    }


}
