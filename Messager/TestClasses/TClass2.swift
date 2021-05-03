//
//  TClass2.swift
//  Messager
//
//  Created by Sriram S on 10/03/21.
//

import Foundation


class TClass2 {
    
    
    func startTestListening(){
        
        TestListen.shared.someListner("ChatRoom1") { (str) in
            
            print("Just got \(str) TClass2")
        }
        
        
        
        
    }
    
}
