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
    var startDate: Date?
    var endDate: Date?
    var members: [String:Int]=[:]
    var tasks:[String:Double]=[:]
    //var category:[String]=[]
    
    init(_ projectdata: DataSnapshot) {
        //print("DEBUG_PRINT:get project data")
        self.id = projectdata.key
        
        let valueDictionary = projectdata.value as! [String: AnyObject]
        
        self.title = valueDictionary["title"] as? String
        //print("DEBUG_PRINT:0")
        self.detail = valueDictionary["detail"] as? String
        //print("DEBUG_PRINT:1")
        
        let sDate = valueDictionary["startDate"] as? String
        let sDateD : Double = Double(sDate!)!
        self.startDate = Date(timeIntervalSince1970: TimeInterval(sDateD))
        //print("DEBUG_PRINT:2")
        
        let eDate = valueDictionary["endDate"] as? String
        let eDateD : Double = Double(eDate!)!
        self.endDate = Date(timeIntervalSince1970: TimeInterval(eDateD))
        //print("DEBUG_PRINT:3")
        
        if let members = valueDictionary["members"] as? [String:Int] {
            self.members = members
            //print("DEBUG_PRINT:4")
        }
        
        if let tasks = valueDictionary["tasks"] as? [String:Double] {
            self.tasks = tasks
            //print("DEBUG_PRINT:5")
        }
    }
}
