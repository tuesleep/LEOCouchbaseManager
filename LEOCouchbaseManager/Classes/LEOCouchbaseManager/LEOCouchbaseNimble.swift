//
//  LEOCouchbaseNimble.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 23/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

var LeoDB: CBLDatabase {
    return LEOCouchbaseManager.sharedInstance.database!
}
