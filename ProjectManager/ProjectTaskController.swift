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


    let user = Auth.auth().currentUser!
    var isManager:Bool = false
    var projectId :String!
    var startProjectDate:NSDate!
    var endProjectDate:NSDate!
    var members : [IdBool] = []
    var observe : Bool = false
    
    var tasks:[Tasks]=[]
    var memberNames:[String:String]=[:]
    var names:[String]=[]
    
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    /*
     Cellに値を設定する
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath as IndexPath) as! TableViewCell
        
        cell.task = self.tasks[indexPath.row].label!
        self.names = []
        for member in self.tasks[indexPath.row].chargers.keys {
            self.names.append(self.memberNames[member]!)
        }
        if self.names.count > 0 {
            cell.subtext = self.names.joined(separator: ",")
        }
        cell.status = String(Int(self.tasks[indexPath.row].status! * 100))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TableViewCell
        cell.task = "Task"
        cell.subtext = "Charger"
        cell.status = "Status"
        cell.importance = 4
        //cell.backgroundColor = UIColor.red
        cell.setView()
        let headerView: UIView = cell.contentView
        headerView.backgroundColor = UIColor.red
        return headerView
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:call ProjectTask viewWillAppear")
        super.viewWillAppear(animated)
        
        //print("DEBUG_PRINT:id:\(self.projectId!)")
        
        if !self.observe {
            let setPath = Const.ProjectsPath + "/" + self.projectId
            let projectRef = Database.database().reference().child(setPath)
            projectRef.observe(.value,with:{snapshot in
                //print("DEBUG_PRINT:call project observe:\(snapshot)")
                let theProject = Projects(projectdata:snapshot)
                self.projectTitle.title = theProject.title!
                self.startProjectDate = theProject.startDate!
                self.endProjectDate = theProject.endDate!
                self.isManager = theProject.members[self.user.uid]!
                if self.isManager {
                    self.addTaskButton.isEnabled = true
                }else{
                    self.addTaskButton.isEnabled = false
                }
                for member in theProject.members.keys {
                    let Ref = Database.database().reference().child(Const.UsersPath).child(member).child("name")
                    Ref.observe(.value,with:{snapshot in
                        self.memberNames[member] = snapshot.value as? String
                        //print("DEBUG_PRINT:name:\(self.memberNames)")
                    })
                }
            })
            
            let taskRef = Database.database().reference().child(Const.TasksPath).queryOrdered(byChild:"project").queryEqual(toValue:self.projectId)
            taskRef.observe(.childAdded,with:{snapshot in
                print("DEBUG_PRINT:Add")
                let theTask = Tasks(taskdata:snapshot)
                self.tasks.append(theTask)
                self.taskTable.reloadData()
            })
            
            taskRef.observe(.childChanged,with:{snapshot in
                print("DEBUG_PRINT:Change")
                let theTask = Tasks(taskdata:snapshot)
                self.tasks.append(theTask)
                self.taskTable.reloadData()
            })
            
            taskRef.observe(.childRemoved,with:{snapshot in
                print("DEBUG_PRINT:Remove")
                let theTask = Tasks(taskdata:snapshot)
                let index = self.tasks.index(of:theTask)
                self.tasks.remove(at:index!)
                Database.database().reference().child(Const.TasksPath).child(theTask.id!).removeAllObservers()
                self.taskTable.reloadData()
            })
            
            
            
            self.observe = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        print("DEBUG_PRINT:call ProjectTask viewWillDisappear")
        if self.observe {
            let setPath = Const.ProjectsPath + "/" + self.projectId
            Database.database().reference().child(setPath).removeAllObservers()
            Database.database().reference().child(Const.TasksPath).queryOrdered(byChild:"project").queryEqual(toValue:self.projectId).removeAllObservers()
            self.tasks=[]
            self.observe = false
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
