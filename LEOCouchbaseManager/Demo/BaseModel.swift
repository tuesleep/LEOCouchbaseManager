//
//  BaseModel.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 23/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class BaseModel: LEOCouchbaseModel {
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
    
}
