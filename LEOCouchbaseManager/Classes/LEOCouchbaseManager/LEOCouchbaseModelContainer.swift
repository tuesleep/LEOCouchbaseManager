//
//  LEOCouchbaseModelContainer.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 22/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

/**
 Container provider all models class and class name of project which inherited LEOCouchbaseModel.
 
 */
class LEOCouchbaseModelContainer: NSObject {
    static let sharedInstance : LEOCouchbaseModelContainer = LEOCouchbaseModelContainer()
    
    var modelMap: [String: AnyClass] = [:]
    
    private override init() {
        super.init()
        
        setupModelMap()
        
        LEOCouchbaseLogger.debug(modelMap)
    }
    
    private func setupModelMap() {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses)
        let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

        for i in 0 ..< actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)] {
                let isDirectlyInherit = class_getSuperclass(currentClass) == LEOCouchbaseModel.self
                let isIndirectlyInherit = class_getSuperclass(class_getSuperclass(currentClass)) == LEOCouchbaseModel.self
                
                if isDirectlyInherit || isIndirectlyInherit {
                    self.modelMap[String(describing: currentClass)] = currentClass
                }
            }
        }
        
        allClasses.deallocate(capacity: Int(expectedClassCount))
    }

}
