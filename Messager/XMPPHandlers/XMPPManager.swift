//
//  XMPPManager.swift
//  Riot
//
//  Created by Sriram S on 11/02/21.
//  Copyright © 2021 Justdial Ltd. All rights reserved.
//
import Foundation
import UIKit
import CocoaLumberjack
import XMPPFramework
import MessageKit
import Dispatch


class XMPPManager: NSObject {
    //XMPP
    let XMLNS_MAM = "urn:xmpp:mam:2"
    
    var current_to : XMPPJID?
    
    
    
    static let shared = XMPPManager()
    #if DEBUG
    static let ddLogLevel = DDLogLevel.verbose
    #else
    static let ddLogLevel = DDLogLevel.info
    #endif
    
//    private var hostName: String = "connect.justdial.com"
//    private var hostPort: UInt16 = 443
    
    private var hostName: String = "chatbeta.justdial.com"
    private var hostPort: UInt16 = 5222
    
    
    private var xmppStream: XMPPStream!
    private var xmppReconnect: XMPPReconnect!
    private var xmppRoster: XMPPRoster!
    private var xmppRosterStorage: XMPPRosterCoreDataStorage!
    private var xmppvCardStorage: XMPPvCardCoreDataStorage!
    private var xmppvCardTempModule: XMPPvCardTempModule!
    private var xmppvCardAvatarModule: XMPPvCardAvatarModule!
    
    private var xmppCapabilities: XMPPCapabilities!
    private var xmppCapabilitiesStorage: XMPPCapabilitiesCoreDataStorage!
    private var xmppMessageArchivingStorage: XMPPMessageArchivingCoreDataStorage!
    private var xmppMessageArchivingModule: XMPPMessageArchiving!
    
    private var xmppAutoPing: XMPPAutoPing!
    private var xmppMessageArchiveManagement : XMPPMessageArchiveManagement!
    private var xmppMessageCarbons : XMPPMessageCarbons!
    
    private var userId = ""
    private var password = ""
    
    var isXmppConnected = false
    
    let xmppMessageListener = XMPPMessageListener.shared
    
    
    override init() {
        super.init()
        
        DDLog.add(DDTTYLogger.sharedInstance!, with: XMPPManager.ddLogLevel)
       // delay(4) {
        self.setupXMPP()
       // }
        
        
    }
    
    
    fileprivate func configureXMPP() {
        // Stream Configuration
        xmppStream = XMPPStream()
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppStream.hostPort = hostPort
        xmppStream.hostName = hostName
        xmppStream.enableBackgroundingOnSocket = true
        xmppStream.keepAliveInterval = 30;
        xmppStream.startTLSPolicy = .preferred
        
    }
    
    fileprivate func configureXMPPElements() {
        //Autoping
        xmppAutoPing = XMPPAutoPing(dispatchQueue: DispatchQueue.main)
        xmppAutoPing?.activate(xmppStream)
        xmppAutoPing?.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppAutoPing?.pingInterval = 5
        xmppAutoPing?.pingTimeout = 5
        
        // Reconnect
        self.xmppReconnect = XMPPReconnect()
        
        // Storage
        self.xmppRosterStorage = XMPPRosterCoreDataStorage()
        self.xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage, dispatchQueue: DispatchQueue.main)
        self.xmppRoster.autoFetchRoster = true
        self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = true
        
        self.xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        self.xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage)
        self.xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule)
        
        self.xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance()
        self.xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage)
        
        self.xmppMessageArchivingStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        self.xmppMessageArchivingModule = XMPPMessageArchiving(messageArchivingStorage: xmppMessageArchivingStorage)
        self.xmppMessageArchivingModule.clientSideMessageArchivingOnly = false
        
        self.xmppMessageArchivingModule.activate(self.xmppStream)
        self.xmppMessageArchivingModule.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.xmppMessageArchiveManagement = XMPPMessageArchiveManagement.init()
        self.xmppMessageArchiveManagement.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppMessageArchiveManagement.activate(self.xmppStream)
        
        self.xmppMessageCarbons = XMPPMessageCarbons.init()
        self.xmppMessageCarbons.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppMessageCarbons.activate(self.xmppStream)
        self.xmppMessageCarbons.enable()
        self.xmppMessageCarbons.autoEnableMessageCarbons = true
        
        //Activate xmpp modules
        self.xmppReconnect.activate(self.xmppStream)
        self.xmppRoster.activate(self.xmppStream)
        self.xmppvCardTempModule.activate(self.xmppStream)
        self.xmppvCardAvatarModule.activate(self.xmppStream)
        self.xmppCapabilities.activate(self.xmppStream)
        
        // Add ourself as a delegate to anything we may be interested in
        self.xmppRoster.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func loginWithId(_ userId: String, password: String) {
        if self.xmppStream == nil {
            //  establishConnection()
        }
        self.userId = userId
        self.password = password
        xmppStream.myJID = XMPPJID(string: userId)
        
        do {
            try xmppStream?.connect(withTimeout: XMPPStreamTimeoutNone)
            print("yoyoyoy")
            
        } catch {
            print("connection failed")
        }
    }
    
    fileprivate func authentictae() {
        do {
            try self.xmppStream.authenticate(withPassword: password)
        }
        catch {
            print("not authenticate")
        }
    }
    
    func setupXMPP(){
        
        let session=URLSession.shared
        var urlString = "https://beta3.justdial.com/uttam/jdchat/jidtest.php?sid=snK9mYQjvJ1Yrh34%2FT4Ig2jwCGX9xnpp7pfChGSVs0I%3D&docid=080PXX80.XX80.200518210237.C9S7&utype=owner"
        urlString = "https://beta3.justdial.com/uttam/jdchat/jidtest.php?sid=OhP9UCvd7TlcZBfSKcodG7Dx0%252Bzk59BrBh4c%252FItQDGE%253D&docid=&sdocid=080PXX80.XX80.200518210237.C9S7&utype=admin&refid=DRX4J2W9&prefid="
        urlString = "https://beta3.justdial.com/uttam/jdchat/jidtest.php?sid=G89M71NVIuIaLrYCm6d0N2nj423JxFQ0%2FT%2BUGvWSOL8%3D&docid=&sdocid=&utype=owner&refid=&prefid=&mobile=9535033880"
      urlString = "https://beta3.justdial.com/uttam/jdchat/jid.php?sid=G89M71NVIuIaLrYCm6d0N2nj423JxFQ0%252FT%252BUGvWSOL8%253D&docid=080PXX80.XX80.200625174808.I3W5&sdocid=&utype=owner&refid=&prefid=DRK2G2Z7"
      //  urlString = "https://beta3.justdial.com/uttam/jdchat/jidtest.php?sid=cXesobua2iDfig%252B%252FMgcOokNTAZSuKxE5ByDyQIZn3r4%253D&docid=&sdocid=080PXX80.XX80.200625174808.I3W5&utype=admin&refid=DRZ7L4Y9&prefid="
        
      //  urlString = "https://beta3.justdial.com/uttam/jdchat/jid.php?sid=cXesobua2iDfig%252B%252FMgcOokNTAZSuKxE5ByDyQIZn3r4%253D&docid=&sdocid=080PXX80.XX80.200625174808.I3W5&utype=admin&refid=DRZ7L4Y9&prefid="
        //  urlString = "https://beta3.justdial.com/uttam/jdchat/jid.php?sid=\(GlobalData.userSid)&docid=080PXX80.XX80.200518210237.C9S7&utype=owner"
        
        if let url = URL(string: urlString){
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            session.dataTask(with: request) { (data, response, error) in
                if (error != nil) {
                    return
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let responseObjectNew = json as? NSDictionary
                        if responseObjectNew == nil {
                            return
                        }
                        DispatchQueue.main.async(execute: {
                            self.userId = "\((responseObjectNew?.object(forKey: "sjid"))!)"
                            self.password = "\((responseObjectNew?.object(forKey: "spwd"))!)"
                            if responseObjectNew?.object(forKey: "rjid") != nil && "\((responseObjectNew?.object(forKey: "rjid"))!)".count > 0 {
                                self.current_to = XMPPJID.init(string: "\((responseObjectNew?.object(forKey: "rjid"))!)")

                            }
                            self.configureXMPP()
                            self.configureXMPPElements()
                            self.loginWithId(self.userId, password: self.password)
                        })
                    }catch {
                        print(error)
                    }
                }
            }.resume()
            
        }
    }
    
    func managedObjectContext_roster() -> NSManagedObjectContext{
        return xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    func managedObjectContext_capabilities() -> NSManagedObjectContext{
        return xmppCapabilitiesStorage.mainThreadManagedObjectContext
    }
    
    func sendMessage(_ message : XMPPMessage) {
        
        xmppStream.send(message)
        
    }
}



extension XMPPManager: XMPPMessageCarbonsDelegate {
    
    func xmppMessageCarbons(_ xmppMessageCarbons: XMPPMessageCarbons, didReceive message: XMPPMessage, outgoing isOutgoing: Bool) {
        
        print("MC!!1")
    }
    
    func xmppMessageCarbons(_ xmppMessageCarbons: XMPPMessageCarbons, willReceive message: XMPPMessage, outgoing isOutgoing: Bool) {
        print("MC!!2")

    }
    
 
    
}
extension XMPPManager: XMPPRoomDelegate {
    
    func xmppRoomDidJoin(_ sender: XMPPRoom) {
        print("XMPPRoomDelegate - Joined")
    }
    
    func xmppRoomDidLeave(_ sender: XMPPRoom) {
        print("XMPPRoomDelegate - Left")

    }
    
    func xmppRoomDidCreate(_ sender: XMPPRoom) {
        print("XMPPRoomDelegate - Created")

    }
    
    
    
}


extension XMPPManager: XMPPStreamDelegate, XMPPMessageArchiveManagementDelegate {
    
    //- (void)retrieveMessageArchiveAt:(XMPPJID *)archiveJID withFields:(NSArray *)fields withResultSet:(XMPPResultSet *)resultSet {

    func xmppStreamDidSecure(_ sender: XMPPStream) {
        print("xmppStreamDidSecure")

    }
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("xmppStreamDidDisconnect \(error?.localizedDescription ?? "None")")
    }
    
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didReceiveFormFields iq: XMPPIQ) {
        print("Archive manage1")
    }
    
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didFailToReceiveMessages error: XMPPIQ?) {
        print("Archive manage2")

    }
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didFinishReceivingMessagesWith resultSet: XMPPResultSet) {
        print("Archive manage2")

    }
    
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didReceiveMAMMessage message: XMPPMessage) {
        print("Archive manage3 \(message.description)")

        if let xmppMessage = message.mamResult?.forwardedMessage {
          //  xmppMessageListener.handleMAMMessages(xmppMessage)

            
            
          }

    }
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didFailToReceiveFormFields iq: XMPPIQ) {
        print("Archive manage4")

    }
    
    func xmppStreamWillConnect(_ sender: XMPPStream) {
        print("=====willconnect")
    }
    func xmppStream(_ sender: XMPPStream, didReceive trust: SecTrust, completionHandler: ((Bool) -> Void)) {
        print("=====didReceiveTrust")
        completionHandler(true)
    }
    
    func xmppStream(_ sender: XMPPStream, willSecureWithSettings settings: NSMutableDictionary) {
        print("=====willSecureWithSettings")
        settings.setObject(true, forKey:GCDAsyncSocketManuallyEvaluateTrust as NSCopying)
        //xmppStream.sen
    }
    
    func xmppStream(_ sender: XMPPStream, socketDidConnect socket: GCDAsyncSocket) {
        print("is it secure \(sender.isSecure ? "Yes" : "No")")
        print("Stream: socet connected")
    }
    func xmppStream(_ sender: XMPPStream, didNotRegister error: DDXMLElement) {
        print("Stream: not registered")
    }
    func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
        print("Stream: error")
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("Stream: Authenticated")
        
        self.xmppMessageCarbons.enable()
        self.xmppMessageCarbons.autoEnableMessageCarbons = true
        
        let currentUser = User.init(self.userId, username: "Sriram", email: "", pushId: "", avatarLink: "", status: "")
        saveUserLocallyXMPP(currentUser)
        XMPPMessageListener.shared.listenForSingleMessages()
        
                        let rJID = XMPPJID.init(string: "347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com")
                        let roomStorage : XMPPRoomMemoryStorage = XMPPRoomMemoryStorage.init()
                        let xmppRoom = XMPPRoom.init(roomStorage: roomStorage, jid: rJID!, dispatchQueue: DispatchQueue.main)
                        xmppRoom.activate(self.xmppStream)
                        xmppRoom.addDelegate(self, delegateQueue: DispatchQueue.main)
        
                        xmppRoom.join(usingNickname: "\(self.xmppStream.myJID?.user ?? "")", history: nil, password: nil)
        
        
        
//        delay(4) {
//            if self.current_to != nil {
//                /*
//                 <presence to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com" type="subscribe" xmlns="jabber:client"/>
//
//
//                 <presence from="723557784d383951622b566d715a4b61@chatbeta.justdial.com/2468635232971252263191746" to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com/723557784d383951622b566d715a4b61" xmlns="jabber:client"><x xmlns="http://jabber.org/protocol/muc"/></presence>
//
//
//                 <presence xmlns="jabber:client"/>
//
//
//                 <presence to="724a57784d633963624f646b704a36653676444d556e4647683263486551764d7839773838707357536b382f31376350687452633479536e5271593d@chatbeta.justdial.com" type="subscribe" xmlns="jabber:client"/>
//
//
//                 <iq id="b63e6531-8818-4534-b6f0-408ee94e6b90:sendIQ" to="724a57784d633963624f646b704a36653676444d556e4647683263486551764d7839773838707357536b382f31376350687452633479536e5271593d@chatbeta.justdial.com" type="get" xmlns="jabber:client"><vCard xmlns="vcard-temp"/></iq>
//
//                 <iq id="1a3b72fb-5669-4500-a22f-0f62926d14f7:sendIQ" to="724a57784d633963624f646b704a36653676444d556e4647683263486551764d7839773838707357536b382f31376350687452633479536e5271593d@chatbeta.justdial.com" type="get" xmlns="jabber:client"><query xmlns="jabber:iq:last"/></iq>
//
//                 **/
//
//
//                print("My JID is \(self.xmppStream.myJID?.user ?? "")")
//
//                let rJID = XMPPJID.init(string: "347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com")
//                let roomStorage : XMPPRoomMemoryStorage = XMPPRoomMemoryStorage.init()
//                let xmppRoom = XMPPRoom.init(roomStorage: roomStorage, jid: rJID!, dispatchQueue: DispatchQueue.main)
//                xmppRoom.activate(self.xmppStream)
//                xmppRoom.addDelegate(self, delegateQueue: DispatchQueue.main)
//
//                xmppRoom.join(usingNickname: "\(self.xmppStream.myJID?.user ?? "")", history: nil, password: nil)
//
//                self.sendPresenceWithStr(#"<presence to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com" type="subscribe" xmlns="jabber:client"/>"#)
//
//
//
//                self.sendPresenceWithStr(#"<presence from="723557784d383951622b566d715a4b61@chatbeta.justdial.com/2468635232971252263191746" to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com/723557784d383951622b566d715a4b61" xmlns="jabber:client"><x xmlns="http://jabber.org/protocol/muc"/></presence>"#)
//
//                self.sendPresenceWithStr(#"<presence xmlns="jabber:client"/>"#)
//
//                self.sendPresenceWithStr(#"<presence to="724a57784d633963624f646b704a36653676444d556e4647683263486551764d7839773838707357536b382f31376350687452633479536e5271593d@chatbeta.justdial.com" type="subscribe" xmlns="jabber:client"/>"#)
//
//
//                self.sendIQWithStr(#"<iq id="b63e6531-8818-4534-b6f0-408ee94e6b90:sendIQ" to="724a57784d633963624f646b704a36653676444d556e4647683263486551764d7839773838707357536b382f31376350687452633479536e5271593d@chatbeta.justdial.com" type="get" xmlns="jabber:client"><vCard xmlns="vcard-temp"/></iq>    "#)
//
//
//
//                self.sendIQWithStr(#"<iq id="1a3b72fb-5669-4500-a22f-0f62926d14f7:sendIQ" to="724a57784d633963624f646b704a36653676444d556e4647683263486551764d7839773838707357536b382f31376350687452633479536e5271593d@chatbeta.justdial.com" type="get" xmlns="jabber:client"><query xmlns="jabber:iq:last"/></iq>"#)
//
//
//
//
//
////                let pres = XMPPPresence.init(type: "subscribe", to: self.current_to!)
////
////           //  let from = XMPPJID.init(string: self.userId)
////                pres.addAttribute(withName: "from", stringValue: self.userId)
////                pres.addAttribute(withName: "xmlns", stringValue: "jabber:client")
////
////
////
////               // pres.from =
////            //pres.elementID = "123123123"
////            sender.send(pres)
//
//
////                let pres3 = try? XMPPPresence.init(xmlString: #"<presence from="723557784d383951622b566d715a4b61@chatbeta.justdial.com" to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com" xmlns="jabber:client"><x xmlns="http://jabber.org/protocol/muc"/></presence>"#)
////
////                sender.send(pres3!)
////
////
////
////
////                let pres2 = try? XMPPPresence.init(xmlString: #"<presence to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com" type="subscribe" xmlns="jabber:client"/>"#)
////
////                sender.send(pres2!)
//
//
//                //<presence from="723557784d383951622b566d715a4b61@chatbeta.justdial.com/16721256987988063575185538" to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com/723557784d383951622b566d715a4b61" xmlns="jabber:client"><x xmlns="http://jabber.org/protocol/muc"/></presence>
//
//
//
//
//
//           // print("Sent Req1 -> \(pres)")
//            print("req1")
//            }
//
//        }
        //723557784d383951622b566d715a4b61@chatbeta.justdial.com
      //  let msg = XMPPMessage.init(type: "randomType", to: XMPPJID.init(string: "723557784d383951622b566d715a4b61@chatbeta.justdial.com/85769535323755872521392258"))
        
       // sender.send(msg)
      //  delay(8) {
        //    self.sendDummyIQ()
       // }
//        }
        //self.sendDummyMessage()
        
        // sender.send(XMPPMessage.ini)
        // self.xmppController.xmppStream.send(XMPPPresence())
        XMPPUserListener.shared.setValueOfArrayOfUsersDummy()

    }
    
    
    func sendPresenceWithStr(_ str : String) {
        
        let pres3 = try? XMPPPresence.init(xmlString: #"<presence from="723557784d383951622b566d715a4b61@chatbeta.justdial.com" to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com" xmlns="jabber:client"><x xmlns="http://jabber.org/protocol/muc"/></presence>"#)
        print("\nDebug77 - 1")
        self.xmppStream.send(pres3!)
        
    }
    
    
    func sendIQWithStr(_ str : String) {
        
        
        let iq = try? XMPPIQ.init(xmlString: #"<presence from="723557784d383951622b566d715a4b61@chatbeta.justdial.com" to="347c326276444e4c74584265453d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com" xmlns="jabber:client"><x xmlns="http://jabber.org/protocol/muc"/></presence>"#)
        print("\nDebug77 - 2")
        self.xmppStream.send(iq!)
        
    }
    
    
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("Stream: Fail to Authenticate")
    }
    func xmppStreamDidRegister(_ sender: XMPPStream) {
        print("Stream: registered")
    }
    
    func xmppStreamDidConnect(_ stream: XMPPStream) {
        print("Stream: Connected")
        isXmppConnected = true
        authentictae()
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        print("\nGot IQ -> \(iq)")
        XMPPMessageListener.shared.handleIncomingIQ(iq)
        return true
    }
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("\nGot Message -> \(message)")

        
        XMPPMessageListener.shared.handleStreamMessage(message)
        
//        if message.isChatMessageWithBody{
//            let user = xmppRosterStorage.user(for: message.from!, xmppStream: xmppStream, managedObjectContext: self.managedObjectContext_roster())
//            let body = "\(message.elements(forName: "body"))"
//            let displayName = user?.displayName
//            if UIApplication.shared.applicationState == .active{
//
//            }else{
//
//            }
//        }
    }
    
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        print(presence)
        let presenceType = presence.type!
        let username = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        
        if presenceFromUser != username  {
            if presenceType == "available" {
                print("available")
            }
            else if presenceType == "subscribe" {
                self.xmppRoster.subscribePresence(toUser: presence.from!)
            }
            else {
                print("presence type"); print(presenceType)
            }
        }
        
    }
    
    
    //didrece
    
    
}

extension XMPPManager: XMPPRosterDelegate {
    
    
    
    func xmppRosterDidEndPopulating(_ sender: XMPPRoster) {
        
        
        XMPPUserListener.shared.pushRosterUpdateEvent()
        
        
    }
    
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterPush iq: XMPPIQ) {
        
    }
    
    func xmppRosterDidBeginPopulating(_ sender: XMPPRoster, withVersion version: String) {
        
        
    }
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterItem item: DDXMLElement) {
        print("$$RosterCheck 3 ITEM \(item.description)")
        XMPPUserListener.shared.handleIncomingRosterItem(item)
    
    }
    func xmppRoster(_ sender: XMPPRoster, didReceivePresenceSubscriptionRequest presence: XMPPPresence) {
       // print("$$RosterCheck 4")
    
    }
    

    
    
}






extension XMPPManager {
    
    
    func fetchMessagesForRoomId(_ roomId : String) {
        
        
        do {
            
            let uuid = UUID()
            print("XMPPTest -> Create worker \(uuid)")
            XMPPMessageListener.shared.createWorker(with: "\(uuid):sendQuery")

            var iq = try? XMPPIQ.init(xmlString: #"<iq id="\#(uuid)" to="\#(roomId)" type="set" xmlns="jabber:client"><query xmlns="urn:xmpp:mam:2" queryid="\#(uuid):sendQuery"><x type="submit" xmlns="jabber:x:data"><field type="hidden" var="FORM_TYPE"><value>urn:xmpp:mam:2</value></field></x><set xmlns="http://jabber.org/protocol/rsm"><max>20</max><before></before></set></query></iq>"#)
            
            
        //    let iqStr = #"<iq id="\#(uuid)" to="\#(roomId)" type="set" xmlns="jabber:client"><query xmlns="urn:xmpp:mam:2 queryid="\#(uuid):sendQuery"><x type="submit" xmlns="jabber:x:data"><field type="hidden" var="FORM_TYPE"><value>urn:xmpp:mam:2</value></field></x><set xmlns="http://jabber.org/protocol/rsm"><max>1</max><before></before></set></query></iq>"#
            
            
            
            //<iq id="d4bfe679-a718-42e8-aad2-65724930c0f2:sendIQ" to="347c326276534d6242524275383d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.connect.justdial.com" type="set" xmlns="jabber:client"><query xmlns="urn:xmpp:mam:2"><x type="submit" xmlns="jabber:x:data"><field type="hidden" var="FORM_TYPE"><value>urn:xmpp:mam:2</value></field></x><set xmlns="http://jabber.org/protocol/rsm"><max>20</max><before></before></set></query></iq>
            
            
            iq = try? XMPPIQ.init(xmlString: #"<iq id="\#(uuid)" to="\#(roomId)" type="set" xmlns="jabber:client"><query xmlns="urn:xmpp:mam:2" queryid="\#(uuid):sendQuery"><x type="submit" xmlns="jabber:x:data"><field type="hidden" var="FORM_TYPE"><value>urn:xmpp:mam:2</value></field></x><set xmlns="http://jabber.org/protocol/rsm"><max>20</max><before></before></set></query></iq>"#)
          //  iq = try? XMPPIQ.init(xmlString: iqStr)
            
            
          //  print("\nRequested IQ ->\(iq)")
//            let dataForm = XMPPElement.init(name: "x", xmlns: "jabber:x:data")
//            dataForm.addAttribute(withName: "type", stringValue: "submit")
//            
//            let formTypeField = XMPPElement.init(name: "type", stringValue: "hidden")
//            formTypeField.addAttribute(withName: "var", stringValue: "FORM_TYPE")
//            
//            formTypeField.addChild(XMPPElement.init(name: "value", stringValue: self.XMLNS_MAM))
//            
//            dataForm.addChild(formTypeField)
//            
//            let setValue = XMPPResultSet.init(max: 20, before: "")

            xmppStream.send(iq!)
            
            
        }catch{
            
            print("xmppDintWOrk")
            
        }
        
        
    }
    
    
    func sendDummyIQ(){
        
//        for i in 0...10 {
//            let identifier = UUID()
//            print("\n11id \(identifier)")
//        }
        
        
        do {
            
            let uuid = UUID()
            print("XMPPTest -> Create worker")
            XMPPMessageListener.shared.createWorker(with: "\(uuid):sendQuery")
            
            
            let iq = try? XMPPIQ.init(xmlString: #"<iq id="\#(uuid)" to="347c326276514d725a58434f383d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b537075374755684572376d63465a6d4f6d7a4e733867354a3153773d3d@conference.chatbeta.justdial.com" type="set" xmlns="jabber:client"><query xmlns="urn:xmpp:mam:2" queryid="\#(uuid):sendQuery"><x type="submit" xmlns="jabber:x:data"><field type="hidden" var="FORM_TYPE"><value>urn:xmpp:mam:2</value></field></x><set xmlns="http://jabber.org/protocol/rsm"><max>20</max><before></before></set></query></iq>"#)
            print("\nRequested IQ ->\(iq)")
            let dataForm = XMPPElement.init(name: "x", xmlns: "jabber:x:data")
            dataForm.addAttribute(withName: "type", stringValue: "submit")
            
            let formTypeField = XMPPElement.init(name: "type", stringValue: "hidden")
            formTypeField.addAttribute(withName: "var", stringValue: "FORM_TYPE")
            
            formTypeField.addChild(XMPPElement.init(name: "value", stringValue: self.XMLNS_MAM))
            
            dataForm.addChild(formTypeField)
            
            let setValue = XMPPResultSet.init(max: 20, before: "")
            if self.current_to != nil {
                self.xmppMessageArchiveManagement.retrieveMessageArchive(at: self.current_to, withFields: nil, with: setValue)
            }
            print("XMPPTest -> Send iq")

            xmppStream.send(iq!)
          //  print("Sent Req2 -> \(iq)")
            
            
            
            
        }catch{
            
            print("xmppDintWOrk")
            
        }
        
    }
    
    
    func sendDummyMessage(){
        var type = ""
        var toStr = XMPPJID.init(string: "723557784d383951622b566d715a4b61@chatbeta.justdial.com/85769535323755872521392258")
        
        var message = XMPPMessage.init(type: type, to: toStr)
        
       // self.xmppStream.send(message)

        
    }
    
    
    
}


func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
