//
//  ProjectTaskController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/13.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ProjectTaskController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var projectTitle: UINavigationItem!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!

    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var projectProgress: UIProgressView!

    @IBOutlet weak var progressLabel: UILabel!

    var isManager:Bool = false
    var projectId :String!
    var startProjectDate:NSDate!
    var endProjectDate:NSDate!
    var observe : Bool = false
    
    var tasks:[Tasks]=[]
    var users :[Users]=[]
    
    @IBAction func handleTaskAdd(_ sender: Any) {
        let addTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddTask") as! AddTaskController
        addTaskViewController.projectId = self.projectId!
        addTaskViewController.isManager = self.isManager
        addTaskViewController.minDate = self.startProjectDate!
        addTaskViewController.maxDate = self.endProjectDate!
        self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
    
    @IBAction func handleProjectDetail(_ sender: Any) {
        let createProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! CreateProjectController
        createProjectViewController.projectId = self.projectId!
        self.navigationController?.pushViewController(createProjectViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT:cell selected")
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            let addTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddTask") as! AddTaskController
            addTaskViewController.taskId = self.tasks[indexPath.row].id!
            addTaskViewController.projectId = self.projectId!
            addTaskViewController.isManager = self.isManager
            addTaskViewController.minDate = self.startProjectDate!
            addTaskViewController.maxDate = self.endProjectDate!
            self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
    
    
    func superReload(){
        print("DEBUG_PRINT:cell superReload")
        let theProject = Const.projects.filter({$0.id == self.projectId})[0]
        let progress:Double = 0.1
        self.projectProgress.progress = Float(progress)
        self.progressLabel.text = String(Int(progress * 100)) + "%"
        
        
        let tasksFilter = Const.tasks.filter({$0.project == self.projectId})
        let users = Const.users.filter({$0.projects[self.projectId]! >= 1})
        let flag1 = tasksFilter.count == theProject.tasks.count
        let flag2 = users.count == theProject.members.count
        if flag1 && flag2 {
            self.taskTable.reloadData()
            
            let term = Const.getTermOfTwoDate(theProject.startDate!,theProject.endDate!)
            
            print("DEBUG_PRINT:term:\(term)")
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("DEBUG_PRINT:numberOfRowsInSection")
        let tasksFilter = Const.tasks.filter({$0.project == self.projectId})
        //print("DEBUG_PRINT:numberOfRowsInSection 1")
        //print("DEBUG_PRINT:Const.users:\(Const.users)")
        self.users = Const.users.filter({$0.projects[self.projectId!]! >= 1})
        //print("DEBUG_PRINT:numberOfRowsInSection 2")
        self.tasks = tasksFilter.sorted(by:{$0.startDate!.timeIntervalSinceReferenceDate > $1.startDate!.timeIntervalSinceReferenceDate})
        //print("DEBUG_PRINT:numberOfRowsInSection 3")
        return self.tasks.count
    }
    
    /*
     Cellに値を設定する
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        //print("DEBUG_PRINT:call cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath as IndexPath) as! TableViewCell
        
        cell.task = self.tasks[indexPath.row].label!
        if self.tasks[indexPath.row].chargers.count > 0{
            let chargersId = self.tasks[indexPath.row].chargers.keys
            var chargersName :[String]=[]
            for charger in chargersId {
                for user in self.users {
                    if charger == user.id! {
                        chargersName.append(user.name!)
                    }
                }
            }
            cell.subtext = chargersName.joined(separator: ",")
        }
        cell.status = self.tasks[indexPath.row].status!
        cell.importance = self.tasks[indexPath.row].importance!
        cell.setView()
        
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //print("DEBUG_PRINT:viewForHeaderInSection")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TableViewCell
        cell.task = "Task"
        cell.subtext = "Charger"
        cell.importance = 4
        //cell.backgroundColor = UIColor.red
        cell.setView()
        let headerView: UIView = cell.contentView
        headerView.backgroundColor = UIColor.red
        return headerView
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //print("DEBUG_PRINT:call ProjectTask viewWillAppear")
        super.viewWillAppear(animated)
        
        //print("DEBUG_PRINT:id:\(self.projectId!)")
        
        if !self.observe {
            
            let taskRef = Database.database().reference().child(Const.TasksPath).queryOrdered(byChild:"project").queryEqual(toValue:self.projectId!)
            
            taskRef.observe(.childAdded,with:{snapshot in
                print("DEBUG_PRINT:[project task] task add")
                let theTask = Tasks(snapshot)
                Const.addTaskData(theTask)
                self.superReload()
            })
            
            
            taskRef.observe(.childChanged,with:{snapshot in
                print("DEBUG_PRINT:[project task] task change")
                let theTask = Tasks(snapshot)
                Const.reloadTaskData(theTask)
                self.superReload()
            })
            
            
            taskRef.observe(.childRemoved,with:{snapshot in
                print("DEBUG_PRINT:[project task] task remove")
                let theTask = Tasks(snapshot)
                Const.removeTaskData(theTask)
                self.superReload()
            })
            
            
            let userRef = Database.database().reference().child(Const.UsersPath).queryOrdered(byChild: "projects/" + self.projectId! ).queryStarting(atValue: 1 )
            
            userRef.observe(.childAdded,with:{snapshot in
                print("DEBUG_PRINT:[project task] user add")
                let theUser = Users(snapshot)
                Const.addUserData(theUser)
                self.superReload()
            })
            
            userRef.observe(.childChanged,with:{snapshot in
                print("DEBUG_PRINT:[project task] user change")
                let theUser = Users(snapshot)
                Const.reloadUserData(theUser)
                self.superReload()
            })
            
            userRef.observe(.childRemoved,with:{snapshot in
                print("DEBUG_PRINT:[project task] user remove")
                let theUser = Users(snapshot)
                Const.removeUserData(theUser)
                self.superReload()
            })
            
            let setPath = Const.ProjectsPath + "/" + self.projectId
            let projectRef = Database.database().reference().child(setPath)
            projectRef.observe(.value,with:{snapshot in
                print("DEBUG_PRINT:[project task] project value")
                let theProject = Projects(snapshot)
                Const.reloadProjectData(theProject)

                self.projectTitle.title = theProject.title!
                self.startProjectDate = theProject.startDate!
                self.endProjectDate = theProject.endDate!
                
                self.isManager = theProject.members[Const.user.id!]! == 2
                if self.isManager {
                    self.addTaskButton.isEnabled = true
                }else{
                    self.addTaskButton.isEnabled = false
                }
                
                self.superReload()
            })
            
            self.observe = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        print("DEBUG_PRINT:call ProjectTask viewWillDisappear")
        if self.observe == true {
            Database.database().reference().child(Const.TasksPath).removeAllObservers()
            Database.database().reference().child(Const.UsersPath).removeAllObservers()
            Database.database().reference().child(Const.ProjectsPath).child(self.projectId!).removeAllObservers()
            self.observe = false
            print("DEBUG_PRINT:[project task] observe off")
        }
        
        super.viewWillDisappear(animated)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.taskTable.delegate = self
        self.taskTable.dataSource = self
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.taskTable.register(nib, forCellReuseIdentifier: "TaskCell")
        self.taskTable.rowHeight = 50.0
        self.taskTable.sectionHeaderHeight = 50
        
        /*
        let cell = self.taskTable.dequeueReusableCell(withIdentifier: "TaskCell") as! TableViewCell
        let headerView: UIView = cell.contentView
        self.taskTable.tableHeaderView = headerView
        */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
