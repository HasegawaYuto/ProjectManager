//
//  IdBool.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/07.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class IdBool: NSObject {
    var id:String?
    var bool:Bool?
    
    init(booldata: DataSnapshot ){
        self.bool = booldata.value as? Bool
        self.id = booldata.key
    }
}
