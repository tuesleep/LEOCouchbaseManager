//
//  LEOCouchbaseManager.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 22/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

/**
 Main manager of LEOCouchbaseManager lib.
 
 Contains database open, replication management, conflict auto dispath to sepcify model handle, register models factory, and setup basic View.
 
 ## Notifications
 
 - LEOCouchbasePushReplicationChangedNotification
 - LEOCouchbasePullReplicationChangedNotification
 
 ## Shortcut
 
 - LeoDB: CBLDatabase global variable
 
 */
class LEOCouchbaseManager: NSObject {
    // MARK: - Private
    
    static let sharedInstance : LEOCouchbaseManager = LEOCouchbaseManager()
    
    var database: CBLDatabase?
    
    private override init() {
        super.init()
    }
    
    private var isRunning = false
    
    private var conflictsLiveQuery: CBLLiveQuery?
    
    // MARK: - Config
    
    var databaseName: String?
    
    var isRegisterModelFactory = true
    
    /**
     The basic View is index of document by **type** key.
     
     */
    var isCreateBasicViews = true
    
    // MARK: - About Sync gateway
    var replicationContainer: LEOReplicationContainer?
    
    var replicationURL: URL?
    var replicationName: String?
    var replicationPassword: String?
    
    /**
     Replication pusher and pull is continuous.
     
     The default value is all true.
     
     ## Cuple
     
     The first is pusher, second is pull.
     
     */
    var replicationContinuous: (Bool, Bool)?
    
    var isStartReplication = false
    var isStartConflictLiveQuery = false
    
    /**
     Start LEO couchbase manager.
     */
    func startManager() {
        guard isRunning == false else {
            LEOCouchbaseLogger.debug("LEOCouchbaseManager is started, do not start manager again.")
            return
        }
        
        guard databaseName != nil else {
            LEOCouchbaseLogger.debug("LEOCouchbaseManager could not starting, becuase databaseName is nil.")
            return
        }
        
        openDatabase(databaseName!)
        
        if isRegisterModelFactory {
            registerModelFactory()
        }
        
        if isCreateBasicViews {
            LEOCouchbaseBasicView().setupBasicViews()
        }
        
        if isStartReplication && (replicationURL != nil && replicationName != nil && replicationPassword != nil) {
            replicationContainer = LEOReplicationContainer()
            
            if replicationContinuous != nil {
                replicationContainer!.isPusherContinuous = replicationContinuous!.0
                replicationContainer!.isPullerContinuous = replicationContinuous!.1
            }
            
            replicationContainer!.startReplication(replicationURL!, name: replicationName!, password: replicationPassword!)
            
            // Conflict just occur when replication syncing.
            if isStartConflictLiveQuery {
                startConflictLiveQuery()
            }
        }
        
        isRunning = true
    }
    
    func stopManager() {
        if isRunning {
            stopConflictLiveQuery()
            replicationContainer?.stopReplication()
            
            try! LeoDB.close()
            
            isRunning = false
        }
    }
    
    // MARK: - Private setup functions
    
    private func openDatabase(_ name: String) {
        let options = CBLDatabaseOptions()
        options.create = true
        
        database = try! CBLManager.sharedInstance().openDatabaseNamed(name, with: options)
    }
    
    /**
     Register model factory can create model by name.
     
     
     Then init clean way with dynamit type.
     
     ```
     let doc = self.database["Note"]
     let note = CBLModel(forDocument: doc) as Note
     ```
     
     */
    private func registerModelFactory() {
        let factory = database?.modelFactory
        
        let modelMap = LEOCouchbaseModelContainer.sharedInstance.modelMap
        
        modelMap.forEach {
            factory?.registerClass($0.value, forDocumentType: $0.key)
        }
    }
    
    private func startConflictLiveQuery() {
        conflictsLiveQuery = database?.createAllDocumentsQuery().asLive()
        conflictsLiveQuery!.allDocsMode = .onlyConflicts
        conflictsLiveQuery!.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        conflictsLiveQuery!.start()
    }
    
    private func stopConflictLiveQuery() {
        conflictsLiveQuery?.removeObserver(self, forKeyPath: "rows")
        conflictsLiveQuery?.stop()
        conflictsLiveQuery = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == conflictsLiveQuery {
            resolveConflicts()
        }
    }
    
    // MARK: - Conflicts
    
    private func resolveConflicts() {
        let rows = conflictsLiveQuery?.rows
        
        while let row = rows?.nextRow() {
            if let revs = row.conflictingRevisions, revs.count > 1 {
                let defaultWinning = revs[0]
                let type = (defaultWinning["type"] as? String) ?? ""
                
                if let modelClass = LEOCouchbaseModelContainer.sharedInstance.modelMap[type] as? LEOCouchbaseModel.Type
                {
                    // Use model conflict implement.
                    modelClass.leo_conflict(revs: revs)
                }
            }
        }
    }
    
}
