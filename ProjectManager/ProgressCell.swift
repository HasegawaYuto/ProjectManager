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
    
    func setProgress(_ project:Projects, _ task:Tasks , _ term : Int){
        //print("DEBUG_PRINT:call setProgress:\(term)")
        
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let projectStart = project.startDate!
        let theDay = calendar.date(byAdding: NSCalendar.Unit.day, value: term, to: projectStart as Date)! as NSDate
        let theDayStart = Const.getLatestMidnight(theDay)
        let theDayEnd = Const.getNextMidnight(theDay)
        let oneDayTerm = theDayEnd.timeIntervalSinceReferenceDate - theDayStart.timeIntervalSinceReferenceDate
        
        
        let taskPlanStart = task.startDate!.timeIntervalSinceReferenceDate
        let taskPlanEnd = task.endDate!.timeIntervalSinceReferenceDate
        
        let flag2 = theDayEnd.timeIntervalSinceReferenceDate <= taskPlanStart
        let flag1 = theDayStart.timeIntervalSinceReferenceDate >= taskPlanEnd
        
        if flag1 || flag2 {
            self.planProgress.isHidden = true
        }else{
            self.planProgress.isHidden = false
            if self.isInDate(task.startDate!,theDayStart,theDayEnd)  {
                let taskStartFromTheMidnight = taskPlanStart - theDayStart.timeIntervalSinceReferenceDate
                let cellLeftMargin = ( taskStartFromTheMidnight / oneDayTerm ) * 49
                self.leftSideP.constant = CGFloat(cellLeftMargin)
            } else {
                self.leftSideP.constant = 0
            }
            
            if self.isInDate(task.endDate!,theDayStart,theDayEnd)   {
                let taskEndFromTheMidnight = theDayEnd.timeIntervalSinceReferenceDate - taskPlanEnd
                let cellRightMargin = ( taskEndFromTheMidnight / oneDayTerm ) * 49
                self.rightSideP.constant = CGFloat(cellRightMargin)
            } else {
                self.rightSideP.constant = 0
            }
        }
        
        if task.realStartDate != nil && task.realStartDate!.timeIntervalSinceReferenceDate < theDayEnd.timeIntervalSinceReferenceDate {
            var realEndDate:NSDate!
            if task.realEndDate != nil {
                realEndDate = task.realEndDate!
            }else{
                realEndDate = NSDate()
            }
            let taskRealStart = task.realStartDate!.timeIntervalSinceReferenceDate
            let taskRealEnd = realEndDate.timeIntervalSinceReferenceDate
            
            if self.isInDate(task.realStartDate!,theDayStart,theDayEnd) {
                self.actuallyProgress.isHidden = false
                let taskStartFromTheMidnight = taskRealStart - theDayStart.timeIntervalSinceReferenceDate
                let cellLeftMargin = ( taskStartFromTheMidnight / oneDayTerm ) * 49
                self.leftSideA.constant = CGFloat(cellLeftMargin)
            }
            if realEndDate.timeIntervalSinceReferenceDate > theDayStart.timeIntervalSinceReferenceDate {
                self.actuallyProgress.isHidden = false
                if self.isInDate(realEndDate,theDayStart,theDayEnd) {
                    let taskEndFromTheMidnight = theDayEnd.timeIntervalSinceReferenceDate - taskRealEnd
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
            let theDateI = theDate.timeIntervalSinceReferenceDate
            let theDayStartI = theDayStart.timeIntervalSinceReferenceDate
            let theDayEndI = theDayEnd.timeIntervalSinceReferenceDate
        
        if theDateI >= theDayStartI && theDateI <= theDayEndI {
            return true
        } else {
            return false
        }
    }

}
