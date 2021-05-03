//
//  TestListen.swift
//  Messager
//
//  Created by Sriram S on 10/03/21.
//

import Foundation

class TestListen {
    
    static let shared = TestListen()
    
    private init() {}
    
    
    func someListner (_ someStr : String, completion : @escaping (_ closureInputStr : String) -> Void) {
        var k = 0
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            
            k += 1
            completion("Completion Result \(k)")
            
        }
        
    }
    
    
}
