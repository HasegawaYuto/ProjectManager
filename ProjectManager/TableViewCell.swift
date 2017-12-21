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
    
    var task:String = "task"
    var status:Double = -1
    var subtext:String = "none"
    var importance:Double = 3
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(){
        self.actionTask.text = self.task
        /*
        0~1->%,working
        2->locked
        3->ready
        4->review
        5->debug
        6->finish
        7->stop
        */
        self.statusLabel2.text = "status"
        self.statusLabel.text = "%"
        if self.status >= 0 && self.status <= 1 {
            self.statusLabel.text = String(Int(self.status * 100))
            self.statusLabel2.text = "Working"
        }else if self.status == 2 {
            self.statusLabel.text = "0"
            self.statusLabel2.text = "Locked"
        }else if self.status == 3 {
            self.statusLabel.text = "0"
            self.statusLabel2.text = "Ready"
        }else if self.status == 4 {
            self.statusLabel.text = "100"
            self.statusLabel2.text = "Review"
        }else if self.status == 5 {
            self.statusLabel.text = "-"
            self.statusLabel2.text = "Debug"
        }else if self.status == 6 {
            self.statusLabel.text = "-"
            self.statusLabel2.text = "Finish"
        }else if self.status == 7 {
            self.statusLabel.text = "-"
            self.statusLabel2.text = "Stop"
        }
        
        self.subLabel.text = self.subtext
        self.importanceView.rating = self.importance
        self.statusLabel.adjustsFontSizeToFitWidth = true
        self.statusLabel2.adjustsFontSizeToFitWidth = true
        self.subLabel.adjustsFontSizeToFitWidth = true
    }
    
}
