//
//  Notebook.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 23/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

@objc(Notebook)
class Notebook: BaseModel {
    @NSManaged var name: String!
    
    override func subRelationTypes() -> [AnyClass]? {
        return [Note.self]
        
        
    }
    
    override class func conflict(revs: [CBLSavedRevision]) {
        LEOCouchbaseLogger.debug("Notebook Conflict..")
    }
}
