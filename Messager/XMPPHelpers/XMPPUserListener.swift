//
//  FirebaseUserListener.swift
//  Messager
//
//  Created by David Kababyan on 19/08/2020.
//

import Foundation
import Firebase
import RxSwift
import KissXML
import XMPPFramework

@objc class XMPPUserListener : NSObject {
    
    static let shared = XMPPUserListener()
    
    @objc dynamic var arrayOfUsers : [User] = []
    
    @objc dynamic var arrofStr : [String] = []
    
    let disposeBag = DisposeBag()
    
    let subject = BehaviorSubject<[User]>(value: [])
    let typingSubject = PublishSubject<String>()
    private override init () {
       
        
    }
    
    
    

    //MARK: - Roster Handling
    func handleIncomingRosterItem(_ rosterItem : DDXMLElement) {

        if let user = convertRosterItemToUser(rosterItem) {
            
            arrayOfUsers.append(user)
            
        }
        
    }
    
    
    func convertRosterItemToUser(_ rosterItem : DDXMLElement) -> User?{
        
        
        if let askValue = rosterItem.attributeStringValue(forName: "ask"), let jid = rosterItem.attributeStringValue(forName: "jid"), askValue == "subscribe" || askValue == "both" {
            
            
            let user = User.init(jid, username: (jid == "347c326276514d725a58434f383d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b537075374755684572376d63465a6d4f6d7a4e733867354a3153773d3d@conference.chatbeta.justdial.com") ? "Test" : "NonTest", email: "", pushId: "", avatarLink: "", status: "")
            
            return user
            
            
        }
        
        return nil
        
    }
    
    func pushTypingEventForMessage(_ xmppMessage : XMPPMessage){
        
        let jid = "asdkjhashjkd"
        
        typingSubject.onNext(jid)
        
    }
    
    
    func pushRosterUpdateEvent(){
      //  self.arrayOfUsers.removeAll()
//        var user = User.init("337c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com", username: "ZZ Gunjan", email: "", pushId: "", avatarLink: "", status: "")
//        //724a57784d633963624f646b704a36653676444d556e4647683263486551764d7839773838707357536b382f31376350687452633479536e5271593d@connect.justdial.com
//
//        //user = User.init(jid, username: (jid == "347c326276514d725a58434f383d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b537075374755684572376d63465a6d4f6d7a4e733867354a3153773d3d@conference.chatbeta.justdial.com") ? "Test" : "NonTest", email: "", pushId: "", avatarLink: "", status: "")
      let user = User.init("347c326276534d6242524275383d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b53707537475568456f37576f47594765737a395138695a687853513d3d@conference.chatbeta.justdial.com", username: "ZZ Gunjan", email: "", pushId: "", avatarLink: "", status: "")
        
        self.arrayOfUsers.append(user)
        self.arrayOfUsers = self.arrayOfUsers.sorted(by: { (first, second) -> Bool in
            return first.username > second.username
        })
        
        self.subject.onNext(self.arrayOfUsers)
//        XMPPManager.shared.fetchMessagesForRoomId("347c326276514d725a58434f383d7c704e79374d387857624f35746f513d3d7c72644734567151395a2b5a3779664b537075374755684572376d63465a6d4f6d7a4e733867354a3153773d3d@conference.chatbeta.justdial.com")
        for user in arrayOfUsers {
            print("\nRoster User Id->\(user.id)")
            
           // XMPPManager.shared.xmppvCardTempModule.fetchvCardTemp(for: XMPPJID.init(string: user.id)!)
            XMPPManager.shared.fetchMessagesForRoomId(user.id)
            
            
        }
        
    }
    
    
    func setValueOfArrayOfUsersDummy(){
 //       _ = Observable.from([1,2,3,4])
        
//        delay(5) {
//            self.subject.onNext([User.init("id", username: "username", email: "em", pushId: "asdkjas", avatarLink: "asd", status: "asd"),User.init("id11", username: "username11", email: "em11", pushId: "asdkjas11", avatarLink: "asd11", status: "asd11")])
//
////            self.arrayOfUsers = [User.init("id", username: "username", email: "em", pushId: "asdkjas", avatarLink: "asd", status: "asd")]
////            self.arrayOfUsers.append(User.init("id", username: "username", email: "em", pushId: "asdkjas", avatarLink: "asd", status: "asd"))
////
//
//        }
//
//        delay(8) {
//            self.subject.onNext([User.init("id", username: "username", email: "em", pushId: "asdkjas", avatarLink: "asd", status: "asd"),User.init("id11", username: "username11", email: "em11", pushId: "asdkjas11", avatarLink: "asd11", status: "asd11"),User.init("id11", username: "username11", email: "em11", pushId: "asdkjas11", avatarLink: "asd11", status: "asd11"),User.init("id11", username: "username11", email: "em11", pushId: "asdkjas11", avatarLink: "asd11", status: "asd11"),User.init("id11", username: "username11", email: "em11", pushId: "asdkjas11", avatarLink: "asd11", status: "asd11"),User.init("id11", username: "username11", email: "em11", pushId: "asdkjas11", avatarLink: "asd11", status: "asd11")])
//
////            self.arrayOfUsers = [User.init("id", username: "username", email: "em", pushId: "asdkjas", avatarLink: "asd", status: "asd")]
////            self.arrayOfUsers.append(User.init("id", username: "username", email: "em", pushId: "asdkjas", avatarLink: "asd", status: "asd"))
////
//
//        }
        
        
    }
    
    func downloadRosterList(completion: @escaping (_ allUsers : [User]) -> Void) {
        
       
        subject.subscribe { (event) in
            
           // print(event.element!)
            completion(event.element!)
            
        }.disposed(by: disposeBag)
        
        
        
//        self.observe(\XMPPUserListener.arrayOfUsers) { (param1, param2) in
//            print("Users Changed !! 11111")
//        }
//
//        self.observe(\XMPPUserListener.arrayOfUsers, options: .new) { person, change in
//            print("Users Changed !! \(person)")
//           // print("I'm now called \(person.name)")
//        }
        
    }
    
    //MARK: - Login
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil && authDataResult!.user.isEmailVerified {
                
                XMPPUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                
                completion(error, true)
            } else {
                print("email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                
                //send verification email
                authDataResult!.user.sendEmailVerification { (error) in
                    print("auth email sent with error: ", error?.localizedDescription)
                }
                
                //create user and save it
                if authDataResult?.user != nil {
                    
//                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey there I'm using Messager")
                    let user = User.init(authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey there I'm using Messager")
                    saveUserLocally(user)
                    self.saveUserToFireStore(user)
                }
            }
        }
    }
    
    //MARK: - Resend link methods
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }

    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
        
    }
    
    //MARK: - Save users
    func saveUserToFireStore(_ user: User) {
        
//        do {
//            try FirebaseReference(.User).document(user.id).setData(from: user)
//        } catch {
//            print(error.localizedDescription, "adding user")
//        }
    }

    //MARK: - Download
    
    
    
    
    
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print(" Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user ", error)
            }
        }
    }

    
    


    
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void ) {
        
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            
            guard let document = querySnapshot?.documents else {
                print("no documents in all users")
                return
            }
            
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }

    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        
//        var count = 0
//        var usersArray: [User] = []
//        
//        for userId in withIds {
//            
//            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
//                
//                guard let document = querySnapshot else {
//                    print("no document for user")
//                    return
//                }
//                
//                let user = try? document.data(as: User.self)
//
//                usersArray.append(user!)
//                count += 1
//                
//                
//                if count == withIds.count {
//                    completion(usersArray)
//                }
//            }
//        }
    }
    
    //MARK: - Update
    
    func updateUserInFirebase(_ user: User) {
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "updating user...")
        }
    }

    
}
