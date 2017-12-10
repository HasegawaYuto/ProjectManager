//
//  ProjectData.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/05.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ProjectData: NSObject {
/*
{
        "project":{
                        "1":{
                                        "title":"iOSアプリでカレンダーを作る",
                                        "detail":"ホゲホゲ株式会社からの依頼、あんなことができるカレンダーアプリ",
                                        "startDate":2017/10/15(NSDate),
                                        "endDate":2017/10/20(NSDate),
                                        "members":{
                                                    "user1":true,
                                                    "user2":false,
                                                    ...
                                                },
                                        "category":{
                                                    "1",...
                                                },
                                    }
                  },
        "users":{
                    "1":{
                                "uid":"Authentication uid"
                                "invited":{
                                            "6",...
                                            },
                                "projects":{
                                            "1":true,
                                            "7":false,
                                            ...
                                            },
                                "tasks":{
                                            "1":57,
                                            "32":0,
                                            "50":100,
                                            ...
                                        }
                            },
               },
        "category":{
                    "1":{
                                    "label":"プロジェクトの初期設定"
                                    "project":"1"
                                    "tasks":{
                                                "1",...
                                            },
                                },
        "tasks":{
                    "1":{
                                "project":"1",
                                "category":"1"
                                "label":"StoryBoard作成"
                                "detail":"StoryBoardに必要なコントローラーと遷移方法を決める"
                                "startDate":2017/10/15(NSDate),
                                "endDate":2017/10/16(NSDate),
                                "chargers":{
                                            "user1",...
                                        }
                                "level":2(1~3)
                                "status":57(0~100)
                            }
               }
     }
*/
    var id: String?
    var title: String?
    var detail:String?
    var startDate: NSDate?
    var endDate: NSDate?
    //var members: []=[]
    //var task:[]=[]
    var category:[String]=[]
    
    init(projectdata: DataSnapshot) {
        self.id = projectdata.key
        
        let valueDictionary = projectdata.value as! [String: AnyObject]
        
        self.title = valueDictionary["title"] as? String
        self.detail = valueDictionary["detail"] as? String
        
        let sDate = valueDictionary["startDate"] as? String
        self.startDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(sDate!)!)
        
        let eDate = valueDictionary["endDate"] as? String
        self.endDate = NSDate(timeIntervalSinceReferenceDate: TimeInterval(eDate!)!)
        
        //if let membersData = valueDictionary["members"] as? [MemberData] {
        //    self.members = membersData
        //}
        
        //if let tasks = valueDictionary["tasks"] as? [TaskData] {
        //    self.task = tasks
        //}
        
        if let category = valueDictionary["category"] as? [String] {
            self.category = category
        }
    }
}
