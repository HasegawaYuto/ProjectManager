//
//  Const.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/06.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import Foundation

struct Const {
    static let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    static let ProjectsPath = "projects"
    static let UsersPath = "users"
    static let CategorysPath = "categorys"
    static let TasksPath = "tasks"
    
    static var user:Users!
    static var project:Projects!
    static var projects:[Projects]=[]
    static var tasks:[Tasks]=[]
    static var users:[Users]=[]
    static var usersBool : Bool = false
    
    static func getLatestMidnight(_ date:Date)->Date{
        let fixdate = Const.calendar.startOfDay(for: date)
        return fixdate
    }
    static func getNextMidnight(_ date:Date)->Date{
        let fixdate = Const.calendar.startOfDay(for: date)
        let fixdate2 = calendar.date(byAdding: .day, value: 1, to: fixdate)
        return fixdate2!
    }
    
    static func getTermOfTwoDate( _ date1 : Date , _ date2:Date)->Int{
        let Date1 = Const.getLatestMidnight(date1)
        let Date2 = Const.getNextMidnight(date2)
        let term = Const.calendar.dateComponents([.day], from: Date1 , to: Date2).day!
        return term
    }
    
    
    static func isIdInArrayIds( _ theId :String , _ arrayIds : [String] ) ->Bool {
        var result = false
        for id in arrayIds {
            if id == theId {
                result = true
                break
            }
        }
        return result
    }
    
    static func addProjectData( _ theProject:Projects){
        //print("DEBUG_PRINT:call addProjectData")
        let temp = Const.projects.filter({$0.id == theProject.id!})
        if temp.count == 0 {
            Const.projects.insert(theProject,at:0)
        }else{
            Const.reloadProjectData(theProject)
        }
        //print("DEBUG_PRINT:call Const.projects:\(Const.projects.count)")
    }
    
    static func reloadProjectData( _ theProject:Projects){
        //print("DEBUG_PRINT:call reloadProjectData")
        var index = -1
        for project in Const.projects {
            index += 1
            if project.id == theProject.id! {
                Const.projects.remove(at:index)
                Const.projects.insert(theProject,at:index)
                break
            }
        }
        //print("DEBUG_PRINT:call Const.projects:\(Const.projects.count)")
    }
    
    static func removeProjectData( _ theProject:Projects){
        //print("DEBUG_PRINT:call removeProjectData")
        var index = -1
        for project in Const.projects {
            index += 1
            if project.id == theProject.id! {
                Const.projects.remove(at:index)
                break
            }
        }
        //print("DEBUG_PRINT:call Const.projects:\(Const.projects.count)")
    }
    
    static func addUserData( _ theUser:Users){
        //print("DEBUG_PRINT:call addUserData")
        let temp = Const.users.filter({$0.id == theUser.id!})
        if temp.count == 0 {
            Const.users.insert(theUser,at:0)
            //print("DEBUG_PRINT:call addUserData add")
        }else{
            //print("DEBUG_PRINT:call addUserData reload")
            Const.reloadUserData(theUser)
        }
        //print("DEBUG_PRINT:call Const.users:\(Const.users.count)")
    }
    
    
    static func reloadUserData( _ theUser:Users){
        //print("DEBUG_PRINT:call reloadUserData")
        var index = -1
        for user in Const.users {
            index += 1
            if user.id == theUser.id! {
                Const.users.remove(at:index)
                Const.users.insert(theUser,at:index)
                break
            }
        }
        //print("DEBUG_PRINT:call Const.users:\(Const.users.count)")
    }
    
    static func removeUserData( _ theUser:Users){
        //print("DEBUG_PRINT:call removeUserData")
        var index = -1
        for user in Const.users {
            index += 1
            if user.id == theUser.id! {
                Const.users.remove(at:index)
                break
            }
        }
        //print("DEBUG_PRINT:call Const.users:\(Const.users.count)")
    }
    
    static func addTaskData( _ theTask:Tasks){
        //print("DEBUG_PRINT:call addTaskData")
        let temp = Const.tasks.filter({$0.id == theTask.id!})
        if temp.count == 0 {
            Const.tasks.insert(theTask,at:0)
            //print("DEBUG_PRINT:call addTaskData add")
        }else{
            //print("DEBUG_PRINT:call addTaskData reload")
            Const.reloadTaskData(theTask)
        }
        //print("DEBUG_PRINT:call Const.tasks:\(Const.tasks.count)")
    }
    
    
    static func reloadTaskData( _ theTask:Tasks){
        //print("DEBUG_PRINT:call reloadTaskData")
        var index = -1
        for task in Const.tasks {
            index += 1
            if task.id == theTask.id! {
                Const.tasks.remove(at:index)
                Const.tasks.insert(theTask,at:index)
                break
            }
        }
        //print("DEBUG_PRINT:call Const.Tasks:\(Const.tasks.count)")
    }
    
    static func removeTaskData( _ theTask:Tasks){
        //print("DEBUG_PRINT:call removeTaskData")
        var index = -1
        for task in Const.tasks {
            index += 1
            if task.id == theTask.id! {
                Const.tasks.remove(at:index)
                break
            }
        }
        //print("DEBUG_PRINT:call Const.tasks:\(Const.tasks.count)")
    }
    
}
