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
    var startDate:Date?
    var endDate:Date?
    var realStartDate:Date?
    var realEndDate:Date?
    var importance:Double?
    var status:Double?
    var status2:Int?
    var chargers:[String:Bool]=[:]

    init(_ taskdata: DataSnapshot){
        
        let valueDictionary = taskdata.value as! [String: AnyObject]
        self.id = taskdata.key
        self.project = valueDictionary["project"] as? String
        
        let sDate = valueDictionary["startDate"] as? String
        let sDateD : Double = Double(sDate!)!
        self.startDate = Date(timeIntervalSince1970: TimeInterval(sDateD))
        
        let eDate = valueDictionary["endDate"] as? String
        let eDateD : Double = Double(eDate!)!
        self.endDate = Date(timeIntervalSince1970: TimeInterval(eDateD))

        self.label = valueDictionary["label"] as? String
        self.detail = valueDictionary["detail"] as? String
        self.importance = valueDictionary["importance"] as? Double
        self.status = valueDictionary["status"] as? Double
        self.status2 = valueDictionary["status2"] as? Int
        
        if let chargers = valueDictionary["chargers"] as? [String:Bool]{
            self.chargers = chargers
        }
        
        if let rsDate = valueDictionary["realStartDate"] as? String {
            let rsDateD : Double = Double(rsDate)!
            self.realStartDate = Date(timeIntervalSince1970: TimeInterval(rsDateD))
        }
        if let reDate = valueDictionary["realEndDate"] as? String {
            let reDateD : Double = Double(reDate)!
            self.realEndDate = Date(timeIntervalSince1970: TimeInterval(reDateD))
        }
        
    }
}
