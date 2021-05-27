//
//  ChatViewController.swift
//  Messager
//
//  Created by David Kababyan on 26/08/2020.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    
    //MARK: - Views
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()

    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: User.currentUserXMPP!.id, displayName: User.currentUserXMPP!.username)
    
    let refreshController = UIRefreshControl()
    var gallery: GalleryController!

    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0

    var typingCounter = 0
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    let micButton = InputBarButtonItem()

    //Listeners
    var notificationToken: NotificationToken?
    
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!
    
    //MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        
        super.init(nibName: nil, bundle: nil)
        self.messagesCollectionView = MessagesCollectionView_Custom.init(frame: .zero, collectionViewLayout: MessagesCollectionViewFlowLayout_Custom())
        self.chatId = chatId
        self.recipientId = chatId
        self.recipientName = recipientName
        
        registerReusableCells()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func registerReusableCells() {
        messagesCollectionView.register(TextMessageCellCustom.self)
        messagesCollectionView.register(MediaMessageCellCustom.self)
        messagesCollectionView.register(LocationMessageCellCustom.self)
        messagesCollectionView.register(AudioMessageCellCustom.self)
        messagesCollectionView.register(LinkPreviewMessageCellCustom.self)
        messagesCollectionView.register(ContactMessageCellCustom.self)
        
        messagesCollectionView.register(TextMessageCellCustom_Reply.self)
        messagesCollectionView.register(MediaMessageCellCustom_Reply.self)
        messagesCollectionView.register(LocationMessageCellCustom_Reply.self)
        messagesCollectionView.register(AudioMessageCellCustom_Reply.self)
        messagesCollectionView.register(LinkPreviewMessageCellCustom_Reply.self)
        messagesCollectionView.register(ContactMessageCellCustom_Reply.self)
        
   }
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
       // createTypingObserver()
        
        configureLeftBarButton()
        configureCustomTitle()

        configureMessageCollectionView()
        configureGestureRecognizer()
        
        configureMessageInputBar()

        loadChats()
       // listenForNewChats()
       // listenForReadStatusChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       // XMPPRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        XMPPRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }
    
    //MARK: - Configurations
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
    }

    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
    }
    
    private func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside {
            item in
            
            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)

        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titleLabel.text = recipientName
    }
    
    
    
    //MARK: - Load Chats
    private func loadChats() {
                
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            print("Realm changes detected for chatRoom ID->\(self.chatId)")
            //updated message
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)

            case .update(_, _ , let insertions, _):

                for index in insertions {

                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }

            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }

    private func listenForNewChats() {
        XMPPMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
        XMPPMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    //MARK: - Insert Messages
    private func listenForReadStatusChange() {
        
        XMPPMessageListener.shared.listenForReadStatusChange(User.currentId, collectionId: chatId) { (updatedMessage) in
            
            if updatedMessage.status != kSENT {
                self.updateMessage(updatedMessage)
            }
        }
    }
    
    private func insertMessages() {

        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {

        if localMessage.senderId != User.currentId {
            markMessageAsRead(localMessage)
        }
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }

    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES

        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[i])
        }
        
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {

        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }

    //MARK: - UpdateReadMessagesStatus
    func updateMessage(_ localMessage: LocalMessage) {

        for index in 0 ..< mkMessages.count {

            let tempMessage = mkMessages[index]

            if localMessage.id == tempMessage.messageId {

                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate

                RealmManager.shared.saveToRealm(localMessage)

                if mkMessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }

    private func markMessageAsRead(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != User.currentId && localMessage.status != kREAD {

           // XMPPMessageListener.shared.updateMessageInFireStore(localMessage, memberIds: [User.currentId, recipientId])
        }
    }


    //MARK: - Actions
    
    @objc func backButtonPressed() {
        XMPPRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }

    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        if User.currentUserXMPP != nil {
            OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [recipientId])
        }
    }

    
    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            
            self.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            
            self.showImageGallery(camera: false)
        }

        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
            
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            } else {
                print("no access to location")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")

        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing {
            
            if displayingMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            refreshController.endRefreshing()
        }
    }

    //MARK: - Helpers
    private func removeListeners() {
        XMPPTypingListener.shared.removeTypingListener()
        XMPPMessageListener.shared.removeListeners()
    }
    
    private func lastMessageDate() -> Date {
        
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }


    
    //MARK: - Update Typing indicator
    func createTypingObserver() {
        
        XMPPTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        
        typingCounter += 1

        XMPPTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        
        typingCounter -= 1
        
        if typingCounter == 0 {
            XMPPTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    
    func updateTypingIndicator(_ show: Bool) {
        
        subTitleLabel.text = show ? "Typing..." : ""
    }
    
    


    //MARK: - Gallery
    private func showImageGallery(camera: Bool) {
        
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    //MARK: - AudioMessages
    @objc func recordAudio() {
        
        switch longPressGesture.state {
        case .began:
            
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            
            AudioRecorder.shared.finishRecording()
        
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())

                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
                
            } else {
                print("no audio file")
            }
            
            audioFileName = ""
            
        @unknown default:
            print("unknown")
        }

    }

    //MARK:- CollectionView properties
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return messagesDataSource.typingIndicator(at: indexPath, in: messagesCollectionView)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if !(message as! MKMessage).reply {
            
            switch message.kind {
            case .text, .attributedText, .emoji:
                let cell = messagesCollectionView.dequeueReusableCell(TextMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .photo, .video:
                let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .location:
                let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .audio:
                let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .contact:
                let cell = messagesCollectionView.dequeueReusableCell(ContactMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .linkPreview:
                let cell = messagesCollectionView.dequeueReusableCell(LinkPreviewMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .custom:
                return messagesDataSource.customCell(for: message, at: indexPath, in: messagesCollectionView)
            }
            
        }else{
            switch message.kind {
            case .text, .attributedText, .emoji:
                let cell = messagesCollectionView.dequeueReusableCell(TextMessageCellCustom_Reply.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.configureReply(with: (message as! MKMessage), at: indexPath, and: messagesCollectionView)
                cell.messageLabel.backgroundColor = UIColor.red
                return cell
            case .photo, .video:
                let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCellCustom_Reply.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.configureReply(with: (message as! MKMessage), at: indexPath, and: messagesCollectionView)

                return cell
            case .location:
                let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCellCustom_Reply.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .audio:
                let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCellCustom_Reply.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .contact:
                let cell = messagesCollectionView.dequeueReusableCell(ContactMessageCellCustom_Reply.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .linkPreview:
                let cell = messagesCollectionView.dequeueReusableCell(LinkPreviewMessageCellCustom_Reply.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .custom:
                return messagesDataSource.customCell(for: message, at: indexPath, in: messagesCollectionView)
            }
            
            
            
        }
        
    }


}


extension ChatViewController : GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (image) in
                
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("selected video")
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
}

