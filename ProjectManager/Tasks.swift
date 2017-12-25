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
    //var category:String?
    var label:String?
    var detail:String?
    var startDate:NSDate?
    var endDate:NSDate?
    var realStartDate:NSDate?
    var realEndDate:NSDate?
    var importance:Double?
    var status:Double?
    var status2:Int?
    var chargers:[String:Bool]=[:]

    init(_ taskdata: DataSnapshot){
        
        let valueDictionary = taskdata.value as! [String: AnyObject]
        self.id = taskdata.key
        self.project = valueDictionary["project"] as? String
        
        let sDate = valueDictionary["startDate"] as? String
        self.startDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(sDate!)!)
        
        let eDate = valueDictionary["endDate"] as? String
        self.endDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(eDate!)!)

        self.label = valueDictionary["label"] as? String
        self.detail = valueDictionary["detail"] as? String
        self.importance = valueDictionary["importance"] as? Double
        self.status = valueDictionary["status"] as? Double
        self.status2 = valueDictionary["status2"] as? Int
        
        if let chargers = valueDictionary["chargers"] as? [String:Bool]{
            self.chargers = chargers
        }
        
        if let rsDate = valueDictionary["realStartDate"] as? String {
            self.realStartDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(rsDate)!)
        }
        if let reDate = valueDictionary["realEndDate"] as? String {
            self.realEndDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(reDate)!)
        }
        
    }
}
