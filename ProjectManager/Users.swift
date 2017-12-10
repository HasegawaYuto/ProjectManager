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
    //var uid:String?
    var invited:[String]=[]
    var projects:[IdBool]=[] // ex IdBool=["1":true]
    var tasks:[IdInt]=[] // ex IdInt = ["1":36]
    
    init(userdata: DataSnapshot){
        self.id = userdata.key
        
        let valueDictionary = userdata.value as! [String: AnyObject]
        self.name = valueDictionary["name"] as? String
        self.id = valueDictionary["id"] as? String
        
        if let invited = valueDictionary["invite"] as? [String]{
            self.invited = invited
        }
        if let projects = valueDictionary["projects"] as? [IdBool]{
            self.projects = projects
        }
        if let tasks = valueDictionary["tasks"] as? [IdInt]{
            self.tasks = tasks
        }
    }
}
