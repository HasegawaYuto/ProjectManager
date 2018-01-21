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
import PopupDialog

class ProjectTaskController: UIViewController {
    
    @IBOutlet weak var projectTitle: UINavigationItem!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    @IBOutlet weak var dateT: UICollectionView!
    @IBOutlet weak var dateL: UICollectionView!

    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var projectProgress: UIProgressView!

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var sc: UISegmentedControl!
    @IBOutlet weak var sortButton: UIButton!
    

    var isManager:Bool = false
    var projectId :String!
    var startProjectDate:Date!
    var endProjectDate:Date!
    var observe : Bool = false
    var dataObserve : Bool = false
    
    var tasks:[Tasks]=[]
    var users :[Users]=[]
    
    var sortStyle :Int = 0
    var sortContent:Int = 0
    
    @IBAction func sortType(_ sender: Any) {
        if self.sortStyle == 0 {
            self.sortStyle = 1
            let buttonImage = UIImage(named: "reverse")
            self.sortButton.setImage(buttonImage, for: UIControlState.normal)
        } else {
            self.sortStyle = 0
            let buttonImage = UIImage(named: "sort")
            self.sortButton.setImage(buttonImage, for: UIControlState.normal)
        }
        self.superReload()
    }
    
    
    @IBAction func sortContents(_ sender: Any) {
        self.sortContent = self.sc.selectedSegmentIndex
        self.superReload()
    }
    
    
    
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
    
    
    func superReload(){
        let tasksFilter = Const.tasks.filter({$0.project == self.projectId})
        let users = Const.users.filter({$0.projects[self.projectId]! >= 1})
        let projectMember = Const.project.members.filter({$0.1 >= 1})
        let flag1 = tasksFilter.count == Const.project.tasks.count
        let flag2 = users.count == projectMember.count
        print("DEBUG_PRINT:flag1:\(flag1)")
        print("DEBUG_PRINT:flag2:\(flag2)")
        print("DEBUG_PRINT:tasksFilter.count:\(tasksFilter.count)")
        print("DEBUG_PRINT:Const.project.tasks.count:\(Const.project.tasks.count)")
        print("DEBUG_PRINT:users.count:\(users.count)")
        print("DEBUG_PRINT:Const.project.members.count:\(Const.project.members.count)")

        if flag1 && flag2 {
            print("DEBUG_PRINT:reload")
            self.taskTable.reloadData()
            self.dateL.reloadData()
            self.dateT.reloadData()
            var bunbo:Double = 0.0
            var bunsi:Double = 0.0
            for task in self.tasks {
                bunbo = bunbo + task.importance!
                bunsi = bunsi + ( task.importance! * task.status!)
            }
            var projectProgress = 0.0
            if bunbo == 0.0 {
                projectProgress = 0.0
            }else{
                projectProgress = bunsi / bunbo
            }
            self.projectProgress.progress = Float(projectProgress)
            self.progressLabel.text = String(Int(projectProgress * 100)) + "%"
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:appear")
        super.viewWillAppear(animated)
        
        if !self.observe {
            let setPath = Const.ProjectsPath + "/" + self.projectId
            let projectRef = Database.database().reference().child(setPath)
            projectRef.observe(.value,with:{snapshot in
                let theProject = Projects(snapshot)
                Const.reloadProjectData(theProject)

                self.projectTitle.title = theProject.title!
                self.startProjectDate = theProject.startDate!
                self.endProjectDate = theProject.endDate!
                
                Const.project = theProject
                
                self.isManager = theProject.members[Const.user.id!]! == 2
                if self.isManager {
                    self.addTaskButton.isEnabled = true
                }else{
                    self.addTaskButton.isEnabled = false
                }
                
                self.superReload()
                
                if !self.dataObserve {
                
                let taskRef = Database.database().reference().child(Const.TasksPath).queryOrdered(byChild:"project").queryEqual(toValue:self.projectId!)
                
                taskRef.observe(.childAdded,with:{snapshot in
                    print("DEBUG_PRINT:task add")
                    let theTask = Tasks(snapshot)
                    Const.addTaskData(theTask)
                    self.superReload()
                })
                
                
                taskRef.observe(.childChanged,with:{snapshot in
                    let theTask = Tasks(snapshot)
                    Const.reloadTaskData(theTask)
                    self.superReload()
                })
                
                
                taskRef.observe(.childRemoved,with:{snapshot in
                    let theTask = Tasks(snapshot)
                    Const.removeTaskData(theTask)
                    self.superReload()
                })
                
                
                let userRef = Database.database().reference().child(Const.UsersPath).queryOrdered(byChild: "projects/" + self.projectId! ).queryStarting(atValue: 1 )
                
                userRef.observe(.childAdded,with:{snapshot in
                    let theUser = Users(snapshot)
                    Const.addUserData(theUser)
                    self.superReload()
                })
                
                userRef.observe(.childChanged,with:{snapshot in
                    let theUser = Users(snapshot)
                    Const.reloadUserData(theUser)
                    self.superReload()
                })
                
                userRef.observe(.childRemoved,with:{snapshot in
                    let theUser = Users(snapshot)
                    Const.removeUserData(theUser)
                    self.superReload()
                })
                    self.dataObserve = true
                }
            })
            
            self.observe = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        if self.observe == true {
            Database.database().reference().child(Const.TasksPath).removeAllObservers()
            Database.database().reference().child(Const.UsersPath).removeAllObservers()
            Database.database().reference().child(Const.ProjectsPath).child(self.projectId!).removeAllObservers()
            self.observe = false
            self.dataObserve = false
        }
        
        super.viewWillDisappear(animated)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskTable.delegate = self
        self.taskTable.dataSource = self
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.taskTable.register(nib, forCellReuseIdentifier: "TaskCell")
        self.taskTable.rowHeight = 50.0
        self.taskTable.sectionHeaderHeight = 50
        
        self.dateT.delegate = self
        self.dateT.dataSource = self
        
        self.dateL.delegate = self
        self.dateL.dataSource = self
        
        let nib2 = UINib(nibName: "DateLabel", bundle: nil)
        self.dateL.register(nib2,forCellWithReuseIdentifier: "DateLabel")
        
        let nib3 = UINib(nibName: "ProgressCell", bundle: nil)
        self.dateT.register(nib3,forCellWithReuseIdentifier: "ProgressCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//////////////////////////////////

extension ProjectTaskController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("DEBUG_PRINT:viewForHeaderInSection")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TableViewCell
        cell.type = 0
        cell.setView()
        let red :CGFloat = 157 / 255
        let green :CGFloat = 204 / 255
        let blue :CGFloat = 224 / 255
        //cell.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        let headerView: UIView = cell.contentView
        headerView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        //headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let addTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddTask") as! AddTaskController
        addTaskViewController.taskId = self.tasks[indexPath.row].id!
        addTaskViewController.projectId = self.projectId!
        addTaskViewController.isManager = self.isManager
        addTaskViewController.minDate = self.startProjectDate!
        addTaskViewController.maxDate = self.endProjectDate!
        self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
}

extension ProjectTaskController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT:Table cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath as IndexPath) as! TableViewCell
        let theTask = self.tasks[indexPath.row]
        cell.type = 0
        cell.setView(task:theTask)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT:Table numberOfRowsInSection")
        let tasksFilter = Const.tasks.filter({$0.project == self.projectId})
        print("DEBUG_PRINT:ch1")
        self.users = Const.users.filter({$0.projects[self.projectId!]! >= 1})
        print("DEBUG_PRINT:ch2")
        switch(self.sortContent){
        case 0:
            if self.sortStyle == 0 {
                self.tasks = tasksFilter.sorted(by:{$0.startDate! < $1.startDate!})
            }else{
                self.tasks = tasksFilter.sorted(by:{$0.startDate! > $1.startDate!})
            }
        case 1:
            if self.sortStyle == 0 {
                self.tasks = tasksFilter.sorted(by:{$0.status! < $1.status! })
            }else{
                self.tasks = tasksFilter.sorted(by:{$0.status! > $1.status! })
            }
        case 2:
            if self.sortStyle == 0 {
                self.tasks = tasksFilter.sorted(by:{$0.importance! < $1.importance! })
            }else{
                self.tasks = tasksFilter.sorted(by:{$0.importance! > $1.importance! })
            }
        default:
            if self.sortStyle == 0 {
                self.tasks = tasksFilter.sorted(by:{$0.startDate! < $1.startDate!})
            }else{
                self.tasks = tasksFilter.sorted(by:{$0.startDate! > $1.startDate!})
            }
        }
        print("DEBUG_PRINT:ch3:\(self.tasks.count)")
        return self.tasks.count
    }
}



//////////////////////////////////


extension ProjectTaskController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("DEBUG_PRINT:collection numberOfItemsInSection")
        let theProject = Const.projects.filter({$0.id == self.projectId})[0]
        return Const.getTermOfTwoDate(theProject.startDate!,theProject.endDate!)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("DEBUG_PRINT:collection numberOfSections")
        if collectionView.restorationIdentifier == "Header" {
            return 1
        } else {
            return self.tasks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("DEBUG_PRINT:collection cellForItemAt")
        let theProject = Const.projects.filter({$0.id == self.projectId})[0]
        if collectionView.restorationIdentifier == "Header" {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateLabel",for: indexPath as IndexPath) as! DateLabel
        cell.setDayLabel(theProject.startDate!,indexPath.item)
        return cell
            
        } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressCell",for: indexPath as IndexPath) as! ProgressCell
        let theTask = self.tasks[indexPath.section]
        cell.setProgress(theProject.startDate!,theTask,indexPath.item)
        let flag1 = theTask.chargers[Const.user.id!] != nil && theTask.chargers[Const.user.id!]! == true
        let flag2 = theTask.status2! != 0 && theTask.status2! != 4 && theTask.status2! != 6 && theTask.status2! != 2
        if self.isManager || (flag1 && flag2){
            cell.isUserInteractionEnabled = true
        } else{
            cell.isUserInteractionEnabled = false
        }
        return cell
        }
    }
}

extension ProjectTaskController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PopUp(nibName: "PopUp", bundle: nil)
        vc.task = self.tasks[indexPath.section]
        vc.isManager = self.isManager
        let pop = PopupDialog(viewController: vc)
        present(pop, animated: true, completion: nil)
    }
    
}

extension ProjectTaskController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

extension ProjectTaskController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 0{
            self.dateT.contentOffset.y = scrollView.contentOffset.y
        }else if scrollView.tag == 1{
            self.dateT.contentOffset.x = scrollView.contentOffset.x
        }else{
            self.dateL.contentOffset.x = scrollView.contentOffset.x
            self.taskTable.contentOffset.y = scrollView.contentOffset.y
        }
    }
}
