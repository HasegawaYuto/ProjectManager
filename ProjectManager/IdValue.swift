//
//  IdValue.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/14.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class IdValue: NSObject {
    var id:String?
    var value:Double?
    
    init(valuedata:DataSnapshot){
        self.id = valuedata.key
        self.value = valuedata.value as? Double
    }
}
