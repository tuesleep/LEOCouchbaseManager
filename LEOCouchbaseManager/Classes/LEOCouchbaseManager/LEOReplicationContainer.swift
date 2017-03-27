//
//  LEOReplicationContainer.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 23/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class LEOReplicationContainer: NSObject {
    
    var pusher: CBLReplication!
    var puller: CBLReplication!
    
    var isPusherContinuous = true
    var isPullerContinuous = true
    
    func startReplication(_ url: URL, name: String, password: String) {
        pusher = LeoDB.createPushReplication(url)
        puller = LeoDB.createPullReplication(url)
        
        pusher.continuous = isPusherContinuous
        puller.continuous = isPullerContinuous
        
        let authenticator = CBLAuthenticator.basicAuthenticator(withName: name, password: password)
        
        pusher.authenticator = authenticator
        puller.authenticator = authenticator
        
        NotificationCenter.default.addObserver(self, selector: #selector(replicationChanged(_:)), name: NSNotification.Name.cblReplicationChange, object: pusher)
        NotificationCenter.default.addObserver(self, selector: #selector(replicationChanged(_:)), name: NSNotification.Name.cblReplicationChange, object: puller)
        
        pusher.start()
        puller.start()
    }
    
    func stopReplication() {
        pusher.stop()
        puller.stop()
    }
    
    // MARK: - KVO
    
    func replicationChanged(_ notification: NSNotification) {
        guard let noticationObject = notification.object as? CBLReplication else { return }
        
        if noticationObject == pusher {
            if let error = pusher.lastError {
                print("pusher error: \(error)")
            } else {
                print("push successful.")
                NotificationCenter.default.post(name: NSNotification.Name.LEOCouchbasePushReplicationChangedNotification, object: nil)
            }
            
        } else if noticationObject == puller {
            if let error = puller.lastError {
                print("puller error: \(error)")
            } else {
                print("pull successful.")
                NotificationCenter.default.post(name: NSNotification.Name.LEOCouchbasePullReplicationChangedNotification, object: nil)
            }
        }
    }
    
}

// MARK: - Notification name

extension NSNotification.Name {
    public static let LEOCouchbasePullReplicationChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "leo.couchbase.pull.replication.changed")
    public static let LEOCouchbasePushReplicationChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "leo.couchbase.push.replication.changed")
}
