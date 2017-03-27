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
        guard let notificationObject = notification.object as? CBLReplication else { return }
        
        var userInfo = [String: Any]()
        userInfo[LEOCouchbaseReplicationStatusUserInfoKey] = notificationObject.status
        
        var progress = 0.0
        
        // calculate progress if active
        if notificationObject.status == .active {
            let total = notificationObject.changesCount
            if total > 0 {
                progress = Double(notificationObject.completedChangesCount) / Double(total)
            }
        }
        
        if notificationObject == pusher {
            if let error = pusher.lastError {
                LEOCouchbaseLogger.error("pusher error: \(error)")
            } else {
                LEOCouchbaseLogger.debug("push successful.")

                userInfo[LEOCouchbasePushReplicationProgressUserInfoKey] = progress
                
                NotificationCenter.default.post(name: NSNotification.Name.LEOCouchbasePushReplicationChangedNotification, object: userInfo)
            }
            
        } else if notificationObject == puller {
            if let error = puller.lastError {
                LEOCouchbaseLogger.error("puller error: \(error)")
            } else {
                LEOCouchbaseLogger.debug("pull successful.")
                
                userInfo[LEOCouchbasePullReplicationProgressUserInfoKey] = progress
                
                NotificationCenter.default.post(name: NSNotification.Name.LEOCouchbasePullReplicationChangedNotification, object: userInfo)
            }
        }
    }
}

// MARK: - Notification name

extension NSNotification.Name {
    public static let LEOCouchbasePullReplicationChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "leo.couchbase.pull.replication.changed")
    public static let LEOCouchbasePushReplicationChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "leo.couchbase.push.replication.changed")
}

/**
 CBLReplicationStatus
 */
public let LEOCouchbaseReplicationStatusUserInfoKey: String = "leo.couchbase.push.replication.status.user.info.key"

/**
 Double value define replication progress
 */
public let LEOCouchbasePullReplicationProgressUserInfoKey: String = "leo.couchbase.pull.replication.progress.user.info.key"
public let LEOCouchbasePushReplicationProgressUserInfoKey: String = "leo.couchbase.push.replication.progress.user.info.key"
