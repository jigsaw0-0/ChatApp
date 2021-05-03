//
//  TClass1.swift
//  Messager
//
//  Created by Sriram S on 10/03/21.
//

import Foundation

class TClass1 {
    
    
    func startTestListening(){
        
        TestListen.shared.someListner("ChatRoom1") { [weak self] (str) in
            
            print("Just got \(str) TClass1")
        }
        
        
        
        
    }
    
}

