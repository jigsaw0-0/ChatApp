//
//  AppDelegate.swift
//  Messager
//
//  Created by David Kababyan on 16/08/2020.
//

import UIKit
import Firebase
import RealmSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var firstRun: Bool?
    //test
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        performRealmMigration()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        requestPushNotificationPermission()
        
        firstRunCheck()
        
        application.registerForRemoteNotifications()
        
        LocationManager.shared.startUpdating()
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        let _ = XMPPManager.shared

//        let _ = TClass1.init().startTestListening()
        
//        delay(6) {
//            let _ = TClass2.init().startTestListening()
//
//        }
        
        
        return true
    }

    
    func performRealmMigration(){
        
        var configuration = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {

                    // if just the name of your model's property changed you can do this
                    //migration.renameProperty(onType: NotSureItem.className(), from: "text", to: "title")

                    // if you want to fill a new property with some values you have to enumerate
                    // the existing objects and set the new value
//                    migration.enumerateObjects(ofType: LocalUser.className()) { oldObject, newObject in
//                        let text = oldObject!["text"] as! String
//                        newObject!["textDescription"] = "The title is \(text)"
//                    }

                    // if you added a new property or removed a property you don't
                    // have to do anything because Realm automatically detects that
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration

        // opening the Realm file now makes sure that the migration is performed
        let realm = try! Realm()
        
    }
    
    
    
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
    
    
    //MARK: - Remote notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("unable to register for remote notifications ", error.localizedDescription)
    }

    private func requestPushNotificationPermission() {
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, _) in
            
        }
    }
    
    private func updateUserPushId(newPushId: String) {
        
        if var user = User.currentUser {
            user.pushId = newPushId
            saveUserLocally(user)
            XMPPUserListener.shared.updateUserInFirebase(user)
        }
    }
    
    //MARK: - FirstRun
    private func firstRunCheck() {

        firstRun = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstRun! {

            let status = Status.allCases.map { $0.rawValue }
            
            userDefaults.set(status, forKey: kSTATUS)
            userDefaults.set(true, forKey: kFIRSTRUN)
            
            userDefaults.synchronize()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(".......... user push token is ", fcmToken)
        updateUserPushId(newPushId: fcmToken)
    }
    
}
