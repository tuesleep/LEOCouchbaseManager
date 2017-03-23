//
//  ViewController.swift
//  LEOCouchbaseManager
//
//  Created by Leonardo Hammer on 22/03/2017.
//  Copyright © 2017 LeoPub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = LEOCouchbaseModelContainer.sharedInstance
        
        let isResponds = Notebook.classForCoder().responds(to: #selector(LEOCouchbaseModel.conflict(revs:)))
        
        print("responds: \(isResponds)")
        
        if let clazz = Notebook.classForCoder() as? LEOCouchbaseModel.Type {
            clazz.conflict(revs: [])
        }
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

