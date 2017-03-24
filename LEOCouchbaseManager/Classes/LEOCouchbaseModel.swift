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
        let className = String(describing: self.classForCoder)
        var key = lowercasedFirstChar(with: className)
        key.append("Ids")
        
        return key
    }
    
    func parentIdKey() -> String? {
        guard let parentType = parentRelationType() else {
            return nil
        }
        
        var key = lowercasedFirstChar(with: String(describing: parentType))
        key.append("Id")
        
        return key
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
        let className = String(describing: self.classForCoder)
        var key = lowercasedFirstChar(with: className)
        key.append("Id")
        
        return key
    }
    
    /**
     Query sub models by type. The type should exist in *subRelationTypes* array.
     
     */
    func subModels(with type: LEOCouchbaseModel.Type) -> [LEOCouchbaseModel] {
        var subModels = [LEOCouchbaseModel]()
        
        let query = LeoDB.viewNamed(String(describing: type)).createQuery()
        
        do {
            let queryEnumerator = try query.run()
            
            while let row = queryEnumerator.nextRow(), let document = row.document {
                if let relationId = document[self.subRelationKey()] as? String, relationId == self.document!.documentID {
                    if let model = CBLModel(for: document) as? LEOCouchbaseModel {
                        subModels.append(model)
                    }
                }
            }
            
        } catch {
            LEOCouchbaseLogger.error(error)
        }
        
        return subModels
    }
    
    func linkSubModel(_ subModel: LEOCouchbaseModel, save: Bool) {
        let className = String(describing: subModel.classForCoder)
        var key = lowercasedFirstChar(with: className)
        key.append("Ids")
        
        if var ids = value(forKey: key) as? [String] {
            ids.append(subModel.document!.documentID)
            setValue(ids, forKey: key)
        } else {
            let subIds = [subModel.document!.documentID]
            setValue(subIds, forKey: key)
        }
        
        if save {
            try! subModel.save()
        }
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
        guard let parentIdKey = parentIdKey(), let parentDocumentID = value(forKey: parentIdKey) as? String else {
            return
        }
        
        guard let document = LeoDB.document(withID: parentDocumentID), let model = CBLModel(for: document) else {
            return
        }
        
        guard var parentRelationArray = model.value(forKey: parentRelationKey()) as? [String] else {
            return
        }
        
        guard let breakIndex = parentRelationArray.index(of: self.document!.documentID) else {
            return
        }
        
        parentRelationArray.remove(at: breakIndex)
        model.setValue(parentRelationArray, forKey: parentRelationKey())
        
        do {
            try model.save()
        } catch {
            LEOCouchbaseLogger.error(error)
        }
    }
    
    override func save() throws {
        if self.type == nil || self.type!.isEmpty {
            self.type = String(describing: self.classForCoder)
        }
        
        try super.save()
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
