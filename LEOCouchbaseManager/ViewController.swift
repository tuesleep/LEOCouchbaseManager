//
//  ViewController.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 22/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = LEOCouchbaseManager.sharedInstance
        manager.databaseName = "demo-db"
        manager.startManager()
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showAllDocuments))
        
        
        // DEMO CODES...
        
        testDemoData()
        

    }
    
    func testDemoData() {
        let notebook = Notebook(forNewDocumentIn: LeoDB)
        notebook.name = "Default notebook"
        
        let note = Note(forNewDocumentIn: LeoDB)
        note.title = "Untitled"
        note.content = "Today is wunderful"
        
        note.notebookId = notebook.document!.documentID
        
        notebook.leo_linkSubModel(note)
        
        try! notebook.save()
        try! note.save()
        
        let model = CBLModel(for: LeoDB.document(withID: note.document!.documentID)!)
        try! model?.deleteDocument()
    }
    
    func showAllDocuments() {
        LEOCouchbaseLogger.debug("Show all documents: ")
        
        LeoDB.createAllDocumentsQuery().runAsync { (queryEnumerator, error) in
            while let row = queryEnumerator.nextRow(), let document = row.document {
                LEOCouchbaseLogger.debug(document.properties as Any)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
