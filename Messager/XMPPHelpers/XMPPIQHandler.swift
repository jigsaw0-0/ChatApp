//
//  XMPPIQHandler.swift
//  Messager
//
//  Created by Sriram S on 19/04/21.
//

import Foundation
import XMPPFramework

extension XMPPMessageListener {
    
    
    func handleIncomingIQ(_ iq : XMPPIQ) {
        
       // print("\nReceived IQ Type ->\(iq.type ?? "") - \(iq.elementID ?? "")")
        let fin = iq.elements(forName: "fin")
        if fin.count > 0, let iqSet = fin[0].resultSet {
            if let last = iqSet.last, let queryId = fin[0].attributeStringValue(forName: "queryid"), let complete =  fin[0].attributeStringValue(forName: "complete") {
                if complete == "true" {
                    finishWorker(with: queryId)
                }
         //       print("Fin queryId ->\(queryId)")
         //       print("Received last \(last)")

            }
            
        }
    }
    
   // func finishWorker
    
}
