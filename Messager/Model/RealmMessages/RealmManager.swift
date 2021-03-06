//
//  RealmManager.swift
//  Messager
//
//  Created by David Kababyan on 31/08/2020.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() { }
    
    func saveToRealm<T: Object>(_ object: T) {
        
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            print("Error saving realm Object ", error.localizedDescription)
        }
    }
    
    
    func saveToRealmMultiObect<T : Object>(_ objects :[T]) {
        
        
        do {
            
            try realm.write {
                
                
                for obj in objects {
                    realm.add(obj, update: .all)
                }
                
            }
            
            
        }catch{
            
            print("Error saving realm Objectssss ", error.localizedDescription)

        }
        
        
        
    }
    
}
