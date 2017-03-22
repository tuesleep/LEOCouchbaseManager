//
//  LEOCouchbaseModelContainer.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 22/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class LEOCouchbaseModelContainer: NSObject {
    var modelMap: [LEOCouchbaseModel: String]!
    
    override init() {
        super.init()
        
        setupModelMap()
    }
    
    private func setupModelMap() {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses)
        let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

        var leoCouchbaseModeSubClasses = [AnyClass]()
        for i in 0 ..< actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)], class_getSuperclass(currentClass) == LEOCouchbaseModel.self {
                leoCouchbaseModeSubClasses.append(currentClass)
            }
        }
        
        allClasses.deallocate(capacity: Int(expectedClassCount))
        
        print("leoCouchbaseModeSubClasses: \(leoCouchbaseModeSubClasses)")
    }
    
    public func model(with name: String) {
        
    }
}
