//
//  MessageKitError.swift
//  Messager
//
//  Created by Sriram S on 22/05/21.
//

internal struct MessageKitError {
    static let avatarPositionUnresolved = "AvatarPosition Horizontal.natural needs to be resolved."
    static let nilMessagesDataSource = "MessagesDataSource has not been set."
    static let nilMessagesDisplayDelegate = "MessagesDisplayDelegate has not been set."
    static let nilMessagesLayoutDelegate = "MessagesLayoutDelegate has not been set."
    static let notMessagesCollectionView = "The collectionView is not a MessagesCollectionView."
    static let layoutUsedOnForeignType = "MessagesCollectionViewFlowLayout is being used on a foreign type."
    static let unrecognizedSectionKind = "Received unrecognized element kind:"
    static let unrecognizedCheckingResult = "Received an unrecognized NSTextCheckingResult.CheckingType"
    static let couldNotLoadAssetsBundle = "MessageKit: Could not load the assets bundle"
    static let customDataUnresolvedCell = "Did not return a cell for MessageKind.custom(Any)."
    static let customDataUnresolvedSize = "Did not return a size for MessageKind.custom(Any)."
    static let couldNotFindColorAsset = "MessageKit: Could not load the color asset."
}
