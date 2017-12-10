//
//  Categorys.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/07.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Categorys: NSObject {
    var id:String?
    var project:String?
    var tasks:[String]=[]
    
    init(categorydata:DataSnapshot){
        let valueDictionary = categorydata.value as! [String: AnyObject]
        self.project = valueDictionary["project"] as? String
        if let tasks = valueDictionary["tasks"] as? [String]{
            self.tasks = tasks
        }
    }
}
