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
    
    var task:String = "task"
    var status:String = "0"
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
        self.statusLabel.text = self.status
        self.subLabel.text = self.subtext
        self.importanceView.rating = self.importance
        self.statusLabel.adjustsFontSizeToFitWidth = true
    }
    
}
