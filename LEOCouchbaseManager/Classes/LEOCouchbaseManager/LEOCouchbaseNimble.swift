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

func getClassName(_ clazz: AnyClass) -> String {
    let className = String(describing: clazz)
    if className.contains(".") {
        if let name = className.components(separatedBy: ".").last {
            return name
        }
    }

    return className
}
