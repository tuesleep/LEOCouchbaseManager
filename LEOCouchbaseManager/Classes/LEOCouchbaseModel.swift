//
//  LEOCouchbaseModel.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 22/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

/**
 This is base model of other models which exist LEO couchbase manager container.
 
 Every model needs inherted this class.
 
 ## Capbility
 
 - Auto delete relation of sub model data.
 - Query sub models by one function.
 
 ## Global property in CBLModel
 
 - type: The type is base diffence of each model. Normally type is a string equal class name. For example, Notebook model type is "Notebook"
 
 */
class LEOCouchbaseModel: CBLModel {
    
    
    func parentRelationType() -> AnyClass? {
        return nil
    }
    
    func parentRelationKey() -> String {
        return ""
    }
    
    /**
     Must override this function if current model have sub relation model.
     
     ## For example: 
     
     Notebook is a model and it has sub relation is Notes.

     Should override this function: 
     
     ```
     override func subRelationTypes() -> [AnyClass]? {
        return [Note.self]
     }
     ```
     
     And Note add property named *notebookId* relation to Notebook, value is notebook.document.documentID
     
     - returns: a classes of sub model in self had collection relation.
     */
    func subRelationTypes() -> [AnyClass]? {
        return nil
    }
    
    /**
     Override this function if needed to rename sub relation key.
     
     ## Default named:
     
        This model is **Notebook**, sub model is **Note**, relation key is **notebookId**, so **Note** class must had a property named **notebookId**.
     
     It's can make auto link or break relation to be able.
     
     - returns: a property key of sub model in self had collection relation.
     */
    func subRelationKey() -> String {
        let className = String(describing: type)
        var key = lowercasedFirstChar(with: className)
        key.append("Id")
        
        return key
    }
    
    class func conflict(revs: [CBLSavedRevision]) {
        LEOCouchbaseLogger.debug("Conflict..")
    }
    
    private func lowercasedFirstChar(with string: String) -> String {
        var resultString = string
        let firstChar = resultString.characters.first?.description.lowercased()
        
        resultString.characters.remove(at: resultString.characters.startIndex)
        
        return firstChar!.appending(resultString)
    }
    
    private func deleteSubRelationModels() {
        guard let types = subRelationTypes() else {
            return
        }
        
        types.forEach {
            let view = LeoDB.viewNamed(String(describing: $0))
            view.createQuery().runAsync({ (queryEnumerator, error) in
                while let row = queryEnumerator.nextRow(), let document = row.document {
                    if let relationId = document[self.subRelationKey()] as? String, relationId == self.document!.documentID {
                        let model = CBLModel(for: document)
                        try! model?.deleteDocument()
                    }
                }
            })
        }
    }
    
    private func breakParentRelation() {
        
    }
    
    override func deleteDocument() throws {
        if subRelationTypes() != nil {
            deleteSubRelationModels()
        }
        
        if parentRelationType() != nil {
            breakParentRelation()
        }
        
        try super.deleteDocument()
    }
    
}
