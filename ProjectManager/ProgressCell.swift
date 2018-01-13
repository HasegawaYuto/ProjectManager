//
//  ProgressCell.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/22.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit

class ProgressCell: UICollectionViewCell {
    @IBOutlet weak var actuallyProgress: UIProgressView!
    @IBOutlet weak var planProgress: UIProgressView!
    
    //@IBOutlet weak var leftSideA: NSLayoutConstraint!
    //@IBOutlet weak var rightSideA: NSLayoutConstraint!

    @IBOutlet weak var leftSideA: NSLayoutConstraint!
    
    @IBOutlet weak var rightSideA: NSLayoutConstraint!
    
    @IBOutlet weak var leftSideP: NSLayoutConstraint!
    @IBOutlet weak var rightSideP: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setProgress(_ planStart:Date!, _ task:Tasks , _ term : Int){
        let theDay = Const.calendar.date(byAdding: .day, value: term, to: planStart)!
        let theDayStart = Const.getLatestMidnight(theDay)
        let theDayEnd = Const.getNextMidnight(theDay)
        let oneDayTermInt = Const.calendar.dateComponents([.second],from:theDayStart,to:theDayEnd).second!
        let oneDayTerm:Double = Double(oneDayTermInt)
        
        let flag2 = theDayEnd < task.startDate!
        let flag1 = theDayStart > task.endDate!
        let flag3 = task.startDate! == task.endDate!
        
        if flag1 || flag2 || flag3 {
            self.planProgress.isHidden = true
        }else{
            self.planProgress.isHidden = false
            self.leftSideP.constant = 0
            self.rightSideP.constant = 0
            if Const.calendar.isDate(task.startDate!,inSameDayAs:theDayStart){
                let taskStartFromTheMidnightInt = Const.calendar.dateComponents([.second],from:theDayStart,to:task.startDate!).second!
                let taskStartFromTheMidnight : Double = Double(taskStartFromTheMidnightInt)
                let cellLeftMargin:Double = Double( taskStartFromTheMidnight / oneDayTerm ) * 49
                self.leftSideP.constant = CGFloat(cellLeftMargin)
            }
            
            if Const.calendar.isDate(task.endDate!,inSameDayAs:theDayStart){
                let taskEndFromTheMidnightInt = Const.calendar.dateComponents([.second],from:task.endDate!,to:theDayEnd).second!
                let taskEndFromTheMidnight : Double = Double(taskEndFromTheMidnightInt)
                let cellRightMargin = ( taskEndFromTheMidnight / oneDayTerm ) * 49
                self.rightSideP.constant = CGFloat(cellRightMargin)
            }
        }
        
        if task.realStartDate != nil {
            let blueFlag1 = task.realStartDate! < theDayStart
            let blueFlag2 = Const.calendar.isDate(task.realStartDate!,inSameDayAs:theDayStart)
            
            if blueFlag1 || blueFlag2 {
                self.actuallyProgress.isHidden = false
                self.leftSideA.constant = 0
                self.rightSideA.constant = 0
                
                var realEndDate:Date!
                if task.realEndDate != nil {
                    realEndDate = task.realEndDate!
                }else{
                    realEndDate = Date()
                }
            
                if Const.calendar.isDate(task.realStartDate!,inSameDayAs:theDayStart) {
                    let taskStartFromTheMidnightInt = Const.calendar.dateComponents([.second],from:theDayStart,to:task.realStartDate!).second!
                    let taskStartFromTheMidnight : Double = Double(taskStartFromTheMidnightInt)
                    let cellLeftMargin = ( taskStartFromTheMidnight / oneDayTerm ) * 49
                    self.leftSideA.constant = CGFloat(cellLeftMargin)
                }
                
                if realEndDate > theDayStart {
                    if Const.calendar.isDate(realEndDate,inSameDayAs:theDayStart) {
                        let taskEndFromTheMidnightInt = Const.calendar.dateComponents([.second],from:realEndDate,to:theDayEnd).second!
                        let taskEndFromTheMidnight : Double = Double(taskEndFromTheMidnightInt)
                        let cellRightMargin = ( taskEndFromTheMidnight / oneDayTerm ) * 49
                        self.rightSideA.constant = CGFloat(cellRightMargin)
                    }
                }else{
                    self.actuallyProgress.isHidden = true
                }
            } else{
                self.actuallyProgress.isHidden = true
            }
        }else{
            self.actuallyProgress.isHidden = true
        }
    }

}
