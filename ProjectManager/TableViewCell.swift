//
//  TableViewCell.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/15.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Cosmos

class TableViewCell: UITableViewCell {
    @IBOutlet weak var actionTask: UILabel!
    
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var importanceView: CosmosView!
    @IBOutlet weak var statusLabel2: UILabel!
    
    var task:String = "Task"
    var type:Int!
    var status:Double = -1
    var status2:Int = 7
    //var subtext:String = "none"
    var importance:Double = 3
    var chargers :[String:Bool]=[:]
    var users : [Users]=[]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(task:Tasks! = nil){
        print("DEBUG_PRINT:call setView")
        if task != nil {
            self.users = Const.users.filter({$0.projects[task.project!]! >= 1})
            self.task = task.label!
            self.importance = task.importance!
            self.status = task.status!
            self.status2 = task.status2!
            self.chargers = task.chargers
        }
        
        
        
        
        self.actionTask.text = self.task
        
        if self.type == 0 {
            if task != nil {
                let chargersId = self.chargers.keys
                var chargersName :[String]=[]
                for charger in chargersId {
                    for user in self.users {
                        if charger == user.id! {
                            chargersName.append(user.name!)
                        }
                    }
                }
                if chargersName.count > 0  && task.chargers.count > 0{
                    self.subLabel.text = chargersName.joined(separator: ",")
                } else {
                    self.subLabel.text = "No Charger"
                }
            } else {
                self.subLabel.text = "Charger"
            }
        } else if self.type == 1 {
            if task != nil {
                var projectName = ""
                for project in Const.projects {
                    if project.id == task.project {
                        projectName = project.title!
                        break
                    }
                }
                self.subLabel.text = projectName
            }else{
                self.subLabel.text = "Project"
            }
        }
        
        
        /*
        0->locked
        1->ready
        2->stop
        3->working
        4->review
        5->debug
        6->finish
        */
        
        if self.status == -1 {
            self.statusLabel.text = "%"
        } else {
            self.statusLabel.text = String(Int(self.status * 100))
        }
        
        switch(self.status2){
            case 0:
                self.statusLabel2.text = "Locked"
                self.statusLabel2.backgroundColor = UIColor.white
                self.statusLabel.backgroundColor = UIColor.white
                self.statusLabel2.textColor = UIColor.black
                self.statusLabel.textColor = UIColor.black
            case 1:
                self.statusLabel2.text = "Ready"
                self.statusLabel2.backgroundColor = UIColor.green
                self.statusLabel.backgroundColor = UIColor.green
                self.statusLabel2.textColor = UIColor.black
                self.statusLabel.textColor = UIColor.black
            case 2:
                self.statusLabel2.text = "Stop"
                self.statusLabel2.backgroundColor = UIColor.gray
                self.statusLabel.backgroundColor = UIColor.gray
                self.statusLabel2.textColor = UIColor.black
                self.statusLabel.textColor = UIColor.black
            case 3:
                self.statusLabel2.text = "Working"
                self.statusLabel2.backgroundColor = UIColor.yellow
                self.statusLabel.backgroundColor = UIColor.yellow
                self.statusLabel2.textColor = UIColor.black
                self.statusLabel.textColor = UIColor.black
            case 4:
                self.statusLabel2.text = "Review"
                self.statusLabel2.backgroundColor = UIColor.purple
                self.statusLabel.backgroundColor = UIColor.purple
                self.statusLabel2.textColor = UIColor.white
                self.statusLabel.textColor = UIColor.white
            case 5:
                self.statusLabel2.text = "Debug"
                self.statusLabel2.backgroundColor = UIColor.red
                self.statusLabel.backgroundColor = UIColor.red
                self.statusLabel2.textColor = UIColor.white
                self.statusLabel.textColor = UIColor.white
            case 6:
                self.statusLabel2.text = "Finish"
                self.statusLabel2.backgroundColor = UIColor.cyan
                self.statusLabel.backgroundColor = UIColor.cyan
                self.statusLabel2.textColor = UIColor.black
                self.statusLabel.textColor = UIColor.black
            case 7:
                self.statusLabel2.text = "Status"
            default:
                self.statusLabel2.text = "Locked"
        }
        
        self.importanceView.rating = self.importance

        self.statusLabel.adjustsFontSizeToFitWidth = true
        self.statusLabel2.adjustsFontSizeToFitWidth = true
        self.subLabel.adjustsFontSizeToFitWidth = true
    }
    
}
