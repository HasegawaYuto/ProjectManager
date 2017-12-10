//
//  Tasks.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/07.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Tasks: NSObject {
    var id:String?
    var project:String?
    var category:String?
    var label:String?
    var detail:String?
    var startDate:NSDate?
    var endDate:NSDate?
    var level:Int?
    var status:Int?
    var chargers:[String]=[]

    init(taskdata: DataSnapshot){
        let valueDictionary = taskdata.value as! [String: AnyObject]
        
        self.project = valueDictionary["project"] as? String
        self.category = valueDictionary["category"] as? String
        self.label = valueDictionary["label"] as? String
        self.detail = valueDictionary["detail"] as? String
        self.level = valueDictionary["level"] as? Int
        self.status = valueDictionary["status"] as? Int
        if let chargers = valueDictionary["chargers"] as? [String]{
            self.chargers = chargers
        }
    }
}
