//
//  LEOCouchbaseBasicView.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 23/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class LEOCouchbaseBasicView: NSObject {
    
    func setupBasicViews() {
        let models = LEOCouchbaseModelContainer.sharedInstance.modelMap
        let basicViewVersion = "1.0"
        
        models.forEach {
            let className = $0.key
            
            let view = LeoDB.viewNamed(className)
            view.setMapBlock({ (doc, emit) in
                if let type = doc["type"] as? String, type == className {
                    emit(doc["_id"] as! String, doc)
                }
            }, version: basicViewVersion)
        }
    }
    
}
