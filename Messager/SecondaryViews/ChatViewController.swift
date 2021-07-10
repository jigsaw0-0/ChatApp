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
import RxSwift
import PDFKit

class ChatViewController: MessagesViewController {
    open lazy var messageInputBarCustom = InputBarAccessoryView()
    var previewVC : PreviewVC?
    var replyView : UIView!
    var replyLeftLine : UIView!
    var replySenderName : UILabel!
    var replyLabel : UILabel!
    var replyRightImageVIew : UIImageView!
    var onlineStatus = true {
        didSet {
            print("Online Status changed")
        }
        
    }
    
    
    
    var replyObject : Dictionary<String, String>?
    //MARK: - Views
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 50, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .light)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()

    let avatarImageContainer: UIView = {
       let avatarContainer = UIView(frame: CGRect(x: 5, y: 6, width: 34, height: 34))
       let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        imageView.backgroundColor = UIColor.red
        imageView.layer.cornerRadius = 17
        imageView.layer.masksToBounds = true
        avatarContainer.addSubview(imageView)
        imageView.tag = 1
        
        let imageViewStatus = UIImageView(frame: CGRect(x: 26, y: 24, width: 8, height: 8))
        imageViewStatus.backgroundColor = UIColor.green
        imageViewStatus.layer.cornerRadius = 4
        imageViewStatus.layer.masksToBounds = true
        avatarContainer.addSubview(imageViewStatus)
        imageViewStatus.tag = 2
        
        return avatarContainer
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
    
    open override var inputAccessoryView: UIView? {
        return messageInputBarCustom
    }
    
    var composeSubscription : Disposable?
    var composedDisposeBag = DisposeBag()
    weak var timer : Timer?
    
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
        messagesCollectionView.register(DocumentMessageCellCustom.self)

        
        
        messagesCollectionView.register(TextMessageCellCustom_Reply.self)
        messagesCollectionView.register(MediaMessageCellCustom_Reply.self)
        messagesCollectionView.register(LocationMessageCellCustom_Reply.self)
        messagesCollectionView.register(AudioMessageCellCustom_Reply.self)
        messagesCollectionView.register(LinkPreviewMessageCellCustom_Reply.self)
        messagesCollectionView.register(ContactMessageCellCustom_Reply.self)
        messagesCollectionView.register(DocumentMessageCellCustom_Reply.self)

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
        
        updateTypingIndicator(false)
        self.subscribeForComposeMessage()
       // listenForNewChats()
       // listenForReadStatusChange()
        
        self.pdfTest()
        
    }
    
    func pdfTest(){
            displayPdf()
        
        
        
        
    }
   
    private func createPdfView(withFrame frame: CGRect) -> PDFView {
        
        let pdfView = PDFView(frame: frame)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        
        return pdfView
    }
    
    
    private func createPdfDocument(forFileName fileName: String) -> PDFDocument? {
        if let resourceUrl = URL(string: "https://images.jdmagicbox.com/chatbot/4b6fbbc7-b79e-20de-efc6-160315bf4369.pdf") {
            return PDFDocument(url: resourceUrl)
        }
        
        return nil
    }
    
    private func displayPdf() {
        let pdfView = self.createPdfView(withFrame: CGRect(x: 0, y: 100, width: 300, height: 200))
        
        if let pdfDocument = self.createPdfDocument(forFileName: "heaps") {
            self.view.addSubview(pdfView)
            pdfView.document = pdfDocument
//            let thumbnailView = PDFThumbnailView()
//
//            thumbnailView.frame = CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 300)
//            thumbnailView.backgroundColor = UIColor.blue
//            self.view.addSubview(thumbnailView)
//            thumbnailView.pdfView = pdfView
            
            
        }
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
    
    
    func subscribeForComposeMessage(){
        
        composeSubscription = XMPPTypingListener.shared.composeSubject.filter{$0.contains(self.chatId)}.subscribe { (event) in
            
            self.updateTypingIndicator(true)
            
        }
        composeSubscription?.disposed(by: composedDisposeBag)
        
        
        
        
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
        
        messageInputBarCustom.delegate = self
        
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
        
        messageInputBarCustom.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBarCustom.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(show: true)
        
        messageInputBarCustom.inputTextView.isImagePasteEnabled = false
        messageInputBarCustom.backgroundView.backgroundColor = .systemBackground
        messageInputBarCustom.inputTextView.backgroundColor = .systemBackground
        
        setupReplyView()
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBarCustom.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBarCustom.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBarCustom.setStackViewItems([messageInputBarCustom.sendButton], forStack: .right, animated: false)
            messageInputBarCustom.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        leftBarButtonView.addSubview(avatarImageContainer)
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
                self.messagesCollectionView.scrollToLastItem(animated: false)

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
            OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [recipientId], replyObject: replyObject)
            replyObject = nil
            refreshReplyView()
        }
    }

    
    private func actionAttachMessage() {
        
        messageInputBarCustom.inputTextView.resignFirstResponder()
        
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
        timer?.invalidate()
        subTitleLabel.text = show ? "Typing..." : (onlineStatus ? "online" : "")
        if show {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(resetTyping), userInfo: nil, repeats: false)
        }
    }
    
    @objc func resetTyping(){
        updateTypingIndicator(false)
        
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
        let documentKind = (message as! MKMessage).documentKind
        if !(message as! MKMessage).reply {
            
            switch message.kind {
            case .text, .attributedText, .emoji:
                let cell = messagesCollectionView.dequeueReusableCell(TextMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .photo, .video:
                if documentKind {
                    let cell = messagesCollectionView.dequeueReusableCell(DocumentMessageCellCustom.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    return cell
                }else{
                let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
                }
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
                // cell.messageLabel.backgroundColor = UIColor.red
                return cell
            case .photo, .video:
                if documentKind {
                    let cell = messagesCollectionView.dequeueReusableCell(DocumentMessageCellCustom_Reply.self, for: indexPath)
                    cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                    cell.configureReply(with: (message as! MKMessage), at: indexPath, and: messagesCollectionView)

                    return cell
                }else{
                let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCellCustom_Reply.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.configureReply(with: (message as! MKMessage), at: indexPath, and: messagesCollectionView)

                return cell
                }
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

    
    
    
     func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        
        return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: {
                    suggestedActions in
                let replyAction =
                    UIAction(title: NSLocalizedString("Reply", comment: ""),
                             image: UIImage(systemName: "arrowshape.turn.up.left")) { action in
                        self.setReplyViewForIndexPath(indexPath)
                    }
                    
                let copyAction =
                    UIAction(title: NSLocalizedString("Copy", comment: ""),
                             image: UIImage(systemName: "plus.square.on.square")) { action in
                    }
                    
//                let deleteAction =
//                    UIAction(title: NSLocalizedString("DeleteTitle", comment: ""),
//                             image: UIImage(systemName: "trash"),
//                             attributes: .destructive) { action in
//                    }
                                                
                return UIMenu(title: "", children: [replyAction, copyAction])
            })
        
    }
    
    func makePreview() -> UIViewController{
        if previewVC == nil {
            previewVC = UIStoryboard.init(name: "MKStoryboard", bundle: nil).instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
            
        }
        previewVC?.view.backgroundColor = UIColor.blue
        return previewVC!
        
    }
     
    
    func setReplyViewForIndexPath(_ indexPath : IndexPath) {
        print("\nIndexPath selected \(indexPath)")
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! MKMessage
        replyObject = [:]
        replyRightImageVIew.image = nil
        let textMessageKind = message.kind
        switch textMessageKind {
        case .text(let text),.emoji(let text):
            self.replyObject!["body"] = text
            self.replyLabel.text = text
            self.replyObject!["msgtype"] = "text"

        case .photo(let photo):
            if let img = photo.image {
                replyRightImageVIew.image = img
            }else{
                
                if let imgURL = photo.url {
                    
                    replyRightImageVIew.sd_setImage(with: imgURL, placeholderImage: nil, options: .progressiveLoad, completed: nil)
                }
            }
            self.replyObject!["msgtype"] = "image"

            self.replyLabel.text = "Photo"
            self.replyObject!["body"] = photo.url?.absoluteString ?? ""
            self.replyObject!["body"] = self.replyObject!["body"]!.replacingOccurrences(of: "file:///", with: "").replacingOccurrences(of: "https:/images", with: "https://images")
        case .video(let video):
            print("Something")
        default:
            print("asd")
            
        }
        self.replyObject!["name"] = "Dummy Name"
        self.replyObject!["msgid"] = message.messageId
        
        refreshReplyView()
        
        
    }
    
    @objc func replyClearAction(_ sender : UIButton) {
        
        replyObject = nil
        refreshReplyView()
        
    }
    
    func refreshReplyView() {
        if replyObject != nil && replyObject!.count > 0 {
            replyView.isHidden = false
        }else{
            replyView.isHidden = true
        }
        
    }
    
    
    
    func setupReplyView() {
        
        replyView = UIView()
        replyLeftLine = UIView()
        replySenderName = UILabel.init()
        replyLabel = UILabel.init()
        replyRightImageVIew = UIImageView.init()
        
        //replyView.backgroundColor = UIColor.blue
        replyView.translatesAutoresizingMaskIntoConstraints = true
        replyView.heightAnchor.constraint(equalToConstant: 56).isActive = true
       // replyView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        (inputAccessoryView as? InputBarAccessoryView)?.topStackView.addArrangedSubview(replyView)
        (inputAccessoryView as? InputBarAccessoryView)?.topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIButton()
        replyView.addSubview(closeButton)
        closeButton.setImage(UIImage.init(systemName: "clear"), for: .normal)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addConstraints(replyView.topAnchor, left: nil, bottom: replyView.bottomAnchor, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 50, heightConstant: 0)
        
        replyView.addSubview(replyLeftLine)
        replyView.addSubview(replySenderName)
        replyView.addSubview(replyLabel)
        replyView.addSubview(replyRightImageVIew)
        
        
        replyLeftLine.addConstraints(replyView.topAnchor, left: replyView.leftAnchor, bottom: replyView.bottomAnchor, right: nil, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 4, heightConstant: 0)
        
        replyLeftLine.backgroundColor = UIColor.replyBubbleColors()[2]
        
        replySenderName.addConstraints(replyView.topAnchor, left: replyLeftLine.rightAnchor, bottom: nil, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 70, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 25)
        replySenderName.textColor = UIColor.replyBubbleColors()[2]
        replySenderName.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        replySenderName.text = "Dummy Name"
        
        replyLabel.addConstraints(replySenderName.bottomAnchor, left: replyLeftLine.rightAnchor, bottom: replyView.bottomAnchor, right: replyView.rightAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 70, centerYConstant: 0, centerXConstant: 0, widthConstant: 0, heightConstant: 0)
       // replyLabel.textColor = UIColor.replyBubbleColors()[2]
        replyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        replyLabel.text = "yo some message"
        replyLabel.textColor = UIColor.replyLabelColor()
        
        
        
        closeButton.addTarget(self, action: #selector(replyClearAction(_:)), for: .touchUpInside)
        
        
        replyRightImageVIew.addConstraints(replyView.topAnchor, left: nil, bottom: replyView.bottomAnchor, right: closeButton.leftAnchor, centerY: nil, centerX: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, centerYConstant: 0, centerXConstant: 0, widthConstant: 50, heightConstant: 0)
        
        
        replyRightImageVIew.contentMode = .scaleAspectFit
        
        
        replyView.isHidden = true
        
        
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

