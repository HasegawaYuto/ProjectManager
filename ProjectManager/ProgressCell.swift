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
    
    func setProgress(_ planStart:NSDate!, _ task:Tasks , _ term : Int){
        //print("DEBUG_PRINT:call setProgress:\(term)")
        
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        //let projectStart = project.startDate!
        let theDay = calendar.date(byAdding: NSCalendar.Unit.day, value: term, to: planStart as Date)! as NSDate
        let theDayStart = Const.getLatestMidnight(theDay)
        let theDayEnd = Const.getNextMidnight(theDay)
        let oneDayTerm = theDayEnd.timeIntervalSince1970 - theDayStart.timeIntervalSince1970
        
        
        let taskPlanStart = task.startDate!.timeIntervalSince1970
        let taskPlanEnd = task.endDate!.timeIntervalSince1970
        
        let flag2 = theDayEnd.timeIntervalSince1970 <= taskPlanStart
        let flag1 = theDayStart.timeIntervalSince1970 >= taskPlanEnd
        
        if flag1 || flag2 {
            self.planProgress.isHidden = true
        }else{
            self.planProgress.isHidden = false
            if self.isInDate(task.startDate!,theDayStart,theDayEnd)  {
                let taskStartFromTheMidnight = taskPlanStart - theDayStart.timeIntervalSince1970
                let cellLeftMargin = ( taskStartFromTheMidnight / oneDayTerm ) * 49
                self.leftSideP.constant = CGFloat(cellLeftMargin)
            } else {
                self.leftSideP.constant = 0
            }
            
            if self.isInDate(task.endDate!,theDayStart,theDayEnd)   {
                let taskEndFromTheMidnight = theDayEnd.timeIntervalSince1970 - taskPlanEnd
                let cellRightMargin = ( taskEndFromTheMidnight / oneDayTerm ) * 49
                self.rightSideP.constant = CGFloat(cellRightMargin)
            } else {
                self.rightSideP.constant = 0
            }
        }
        
        if task.realStartDate != nil && task.realStartDate!.timeIntervalSince1970 <= theDayEnd.timeIntervalSince1970 {
            var realEndDate:NSDate!
            if task.realEndDate != nil {
                realEndDate = task.realEndDate!
            }else{
                realEndDate = NSDate()
            }
            let taskRealStart = task.realStartDate!.timeIntervalSince1970
            let taskRealEnd = realEndDate.timeIntervalSince1970
            
            if self.isInDate(task.realStartDate!,theDayStart,theDayEnd) {
                self.actuallyProgress.isHidden = false
                let taskStartFromTheMidnight = taskRealStart - theDayStart.timeIntervalSince1970
                let cellLeftMargin = ( taskStartFromTheMidnight / oneDayTerm ) * 49
                self.leftSideA.constant = CGFloat(cellLeftMargin)
            }
            if realEndDate.timeIntervalSince1970 >= theDayStart.timeIntervalSince1970 {
                self.actuallyProgress.isHidden = false
                if self.isInDate(realEndDate,theDayStart,theDayEnd) {
                    let taskEndFromTheMidnight = theDayEnd.timeIntervalSince1970 - taskRealEnd
                    let cellRightMargin = ( taskEndFromTheMidnight / oneDayTerm ) * 49
                    self.rightSideA.constant = CGFloat(cellRightMargin)
                }
            }else{
                self.actuallyProgress.isHidden = true
            }
        } else{
            self.actuallyProgress.isHidden = true
        }
        
    }
    
    func isInDate( _ theDate:NSDate, _ theDayStart:NSDate , _ theDayEnd : NSDate)->Bool{
            let theDateI = theDate.timeIntervalSince1970
            let theDayStartI = theDayStart.timeIntervalSince1970
            let theDayEndI = theDayEnd.timeIntervalSince1970
        
        if theDateI >= theDayStartI && theDateI <= theDayEndI {
            return true
        } else {
            return false
        }
    }

}
