//
//  LocalUser.swift
//  Messager
//
//  Created by Sriram S on 15/04/21.
//



import Foundation
import RealmSwift

class LocalUser: Object, Codable {
    
    
    
    @objc dynamic var id = ""
    @objc dynamic var username: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var pushId = ""
    @objc dynamic var avatarLink = ""
    @objc dynamic var status: String = ""
    
  

    override class func primaryKey() -> String? {
        return "id"
    }
}
