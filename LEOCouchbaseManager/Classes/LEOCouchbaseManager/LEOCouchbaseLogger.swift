//
//  LEOCouchbaseLogger.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 23/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class LEOCouchbaseLogger: NSObject {
    class func debug(_ content: Any) {
        print(">> LEOCouchbaseLogger \(self.dateFormat()) [DEBUG]: ", terminator: "")
        print(content)
    }
    
    class func error(_ content: Any) {
        print(">> LEOCouchbaseLogger \(self.dateFormat()) [ERROR]: ", terminator: "")
        print(content)
    }
    
    class func dateFormat() -> String {
        let date = Date()
        
        return date.description
    }
}
