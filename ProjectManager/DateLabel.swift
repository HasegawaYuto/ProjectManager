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
    
    func setDayLabel( _ date:NSDate, _ term:Int){
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let calcDate = calendar.date(byAdding: NSCalendar.Unit.day, value: term, to: date as Date)! as NSDate
        let dateFormatterY = DateFormatter()
        let dateFormatterM = DateFormatter()
        let dateFormatterD = DateFormatter()
        let dateFormatterW = DateFormatter()
        
        dateFormatterY.dateFormat = "yyyy"
        dateFormatterM.dateFormat = "M"
        dateFormatterD.dateFormat = "d"
        dateFormatterW.dateFormat = "E"
        
        let isStartDayOfYear = dateFormatterM.string(from: calcDate as Date) == "1" && dateFormatterD.string(from: calcDate as Date) == "1"
        let isStartDayOfMonth = dateFormatterD.string(from: calcDate as Date) == "1"
        if term == 0 || isStartDayOfYear {
            self.yearL.text = dateFormatterY.string(from: calcDate as Date)
        }else{
            self.yearL.text = ""
        }
        if term == 0 || isStartDayOfMonth {
            self.monthL.text = dateFormatterM.string(from: calcDate as Date)
        }else{
            self.monthL.text = ""
        }
        self.dayL.text = dateFormatterD.string(from: calcDate as Date)
        self.dayWL.text = dateFormatterW.string(from: calcDate as Date)
        
        let components = calendar.components(NSCalendar.Unit.weekday, from: calcDate as Date)
        if components.weekday! == 1 {
            self.backgroundColor = UIColor.red
        }
        if components.weekday! == 7 {
            self.backgroundColor = UIColor.blue
        }
        if components.weekday! > 1 && components.weekday! < 7 {
            self.backgroundColor = UIColor.white
        }
        
        
        self.yearL.adjustsFontSizeToFitWidth = true
        self.monthL.adjustsFontSizeToFitWidth = true
        self.dayL.adjustsFontSizeToFitWidth = true
        self.dayWL.adjustsFontSizeToFitWidth = true
        
        self.isUserInteractionEnabled = false
        
    }

}