//
//  Note.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 23/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

@objc(Note)
class Note: NSObject {
    // Relation id
    @NSManaged var notebookId: String!
    
    @NSManaged var title: String?
    @NSManaged var content: String?
}