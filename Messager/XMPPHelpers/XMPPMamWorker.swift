//
//  XMPPMamWorker.swift
//  Messager
//
//  Created by Sriram S on 19/03/21.
//

import Foundation
import XMPPFramework
import RxSwift

class XMPPMamWorker : XMPPMessageSubscribeListener{
    let disposeBag = DisposeBag()
    var MAMMessageBucket : [LocalMessage] = []
    var id : String = ""
    var queryId = ""
    var subscription : Disposable?
    
    
    init(_ queryId : String) {
        self.id = queryId.replacingOccurrences(of: ":sendQuery", with: "")
        self.queryId = queryId
        self.listenForMessages()
    }
    func listenForMessages(){
        print("XMPPTest -> Listen for messages")
        subscription = XMPPMessageListener.shared.subject.filter{ $0.queryId == self.queryId }.subscribe { (event) in
            print("Got local message in Worker \(self.id)-> \(event.element!.queryId)")
            if let element = event.element {
                self.MAMMessageBucket.append(element)
            }
            self.subscription?.disposed(by: self.disposeBag)
         //   completion(event.element!)
            
        }
        //.disposed(by: disposeBag)
    }
    
    func finish(){
        subscription?.dispose()
        RealmManager.shared.saveToRealmMultiObect(MAMMessageBucket)
        print("Removing MAM Worker")

        XMPPMessageListener.shared.mamWorkers.removeValue(forKey: self.queryId)
        
    }
    
    func messageReceivedFromMam(message: XMPPMessage) {
        
    }
    
    deinit {
        print("Worker deallocated")
    }
    
}

