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
        debugPrint(">> LEOCouchbaseLogger \(self.dateFormat()) [DEBUG]: ", terminator: "")
        debugPrint(content)
    }
    
    class func error(_ content: Any) {
        debugPrint(">> LEOCouchbaseLogger \(self.dateFormat()) [ERROR]: ", terminator: "")
        debugPrint(content)
    }
    
    class func dateFormat() -> String {
        let date = Date()
        
        return date.description
    }
}
