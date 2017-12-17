//
//  Projects.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/07.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Projects: NSObject {
    var id: String?
    var title: String?
    var detail:String?
    var startDate: NSDate?
    var endDate: NSDate?
    var members: [String:Bool]=[:]
    var tasks:[String:Double]=[:]
    //var category:[String]=[]
    
    init(projectdata: DataSnapshot) {
        //print("DEBUG_PRINT:get project data")
        self.id = projectdata.key
        
        let valueDictionary = projectdata.value as! [String: AnyObject]
        
        self.title = valueDictionary["title"] as? String
        self.detail = valueDictionary["detail"] as? String
        
        let sDate = valueDictionary["startDate"] as? String
        self.startDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(sDate!)!)
        
        let eDate = valueDictionary["endDate"] as? String
        self.endDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(eDate!)!)
        
        if let members = valueDictionary["members"] as? [String:Bool] {
            self.members = members
        }
        
        if let tasks = valueDictionary["tasks"] as? [String:Double] {
            self.tasks = tasks
        }
    }
}
