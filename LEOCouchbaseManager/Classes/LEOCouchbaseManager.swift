//
//  LEOCouchbaseManager.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 22/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class LEOCouchbaseManager: NSObject {
    // MARK: - Private
    
    private var database: CBLDatabase!
    private var isRunning = false
    
    private var conflictsLiveQuery: CBLLiveQuery?
    
    // MARK: - Config
    
    var databaseName: String!
    
    var isRegisterModelFactory = true
    
    var isStartConflictLiveQuery = true
    
    init(_ databaseName: String) {
        super.init()
        self.databaseName = databaseName
    }
    
    /**
     Start LEO couchbase manager.
     */
    func startManager() {
        guard isRunning == false else {
            print("Warnning: LEOCouchbaseManager is running, do not start manager again.")
            return
        }
        
        openDatabase(databaseName)
        
        if isStartConflictLiveQuery {
            startConflictLiveQuery()
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
        let factory = database.modelFactory
        
//        factory?.registerClass(Notebook.self, forDocumentType: "Notebook")
//        factory?.registerClass(Note.self, forDocumentType: "Note")
//        factory?.registerClass(NoteItem.self, forDocumentType: "NoteItem")
//        factory?.registerClass(Image.self, forDocumentType: "Image")
        
        // Another model to be continue...
    }
    
    private func startConflictLiveQuery() {
        conflictsLiveQuery = database.createAllDocumentsQuery().asLive()
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
        
        print("conflicts: \(rows?.count) --------------------")
        
        while let row = rows?.nextRow() {
            print("row: \(row)")
            if let revs = row.conflictingRevisions, revs.count > 1 {
//                let defaultWinning = revs[0]
//                let type = (defaultWinning["type"] as? String) ?? ""
                
                // Solving conflict by type
//                switch type {
//                case "NoteItem":
//                    solveNoteItemConflict(revs)
//                default:
//                    break
//                }
            }
        }
    }
    
    
    
}
