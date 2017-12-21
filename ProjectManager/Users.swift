//
//  Users.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/06.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Users: NSObject {
    var id:String?
    var name:String?
    var mail:String?
    //var invited:[String:Bool]=[:]
    var projects:[String:Int]=[:] // ex IdBool=["1":true]
    var tasks:[String:Bool]=[:] // ex IdInt = ["1":36]
    
    init( _ userdata: DataSnapshot){
        self.id = userdata.key
        
        let valueDictionary = userdata.value as! [String: AnyObject]
        self.name = valueDictionary["name"] as? String
        self.mail = valueDictionary["mail"] as? String
        
        /*
        if let inviteds = valueDictionary["invited"] as? [String:Bool]{
            self.invited = inviteds
        }
        */

        if let projects = valueDictionary["projects"] as? [String:Int]{
            self.projects = projects
        }
        
        if let tasks = valueDictionary["tasks"] as? [String:Bool]{
            self.tasks = tasks
        }
    }
}
