//
//  DateLabel.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/22.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit

class DateLabel: UICollectionViewCell {

    @IBOutlet weak var yearL: UILabel!
    @IBOutlet weak var monthL: UILabel!
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var dayWL: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDayLabel( _ date:Date, _ term:Int){
        let calcDate = Const.calendar.date(byAdding: .day, value: term, to: date as Date)!
        let dateFormatterY = DateFormatter()
        let dateFormatterM = DateFormatter()
        let dateFormatterD = DateFormatter()
        let dateFormatterW = DateFormatter()
        
        dateFormatterY.dateFormat = "yyyy"
        dateFormatterM.dateFormat = "M"
        dateFormatterD.dateFormat = "d"
        dateFormatterW.dateFormat = "E"
        
        let isStartDayOfYear = dateFormatterM.string(from: calcDate) == "1" && dateFormatterD.string(from: calcDate) == "1"
        let isStartDayOfMonth = dateFormatterD.string(from: calcDate) == "1"
        if term == 0 || isStartDayOfYear {
            self.yearL.text = dateFormatterY.string(from: calcDate)
        }else{
            self.yearL.text = ""
        }
        if term == 0 || isStartDayOfMonth {
            self.monthL.text = dateFormatterM.string(from: calcDate)
        }else{
            self.monthL.text = ""
        }
        self.dayL.text = dateFormatterD.string(from: calcDate)
        self.dayWL.text = dateFormatterW.string(from: calcDate)
        
        let components = Const.calendar.dateComponents([.weekday], from: calcDate)
        if components.weekday! == 1 {
            self.backgroundColor = UIColor.red
            self.yearL.textColor = UIColor.white
            self.monthL.textColor = UIColor.white
            self.dayL.textColor = UIColor.white
            self.dayWL.textColor = UIColor.white
        }
        if components.weekday! == 7 {
            self.backgroundColor = UIColor.blue
            self.yearL.textColor = UIColor.white
            self.monthL.textColor = UIColor.white
            self.dayL.textColor = UIColor.white
            self.dayWL.textColor = UIColor.white
        }
        if components.weekday! > 1 && components.weekday! < 7 {
            self.backgroundColor = UIColor.white
            self.yearL.textColor = UIColor.black
            self.monthL.textColor = UIColor.black
            self.dayL.textColor = UIColor.black
            self.dayWL.textColor = UIColor.black
        }
        
        
        self.yearL.adjustsFontSizeToFitWidth = true
        self.monthL.adjustsFontSizeToFitWidth = true
        self.dayL.adjustsFontSizeToFitWidth = true
        self.dayWL.adjustsFontSizeToFitWidth = true
        
        self.isUserInteractionEnabled = false
        
    }

}
