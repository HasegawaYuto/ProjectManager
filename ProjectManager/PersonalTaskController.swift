//
//  PersonalTaskController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/08.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import PopupDialog
import GoogleMobileAds

class PersonalTaskController: UIViewController {
    @IBOutlet weak var taskT: UITableView!
    @IBOutlet weak var dateT: UICollectionView!
    @IBOutlet weak var progressT: UICollectionView!
    //@IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var badView: GADBannerView!
    
    
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sc: UISegmentedControl!
    
    var userId :String!
    //var startTasksDate:Date!
    //var endTasksDate:Date!
    var observeUserBool : Bool = false
    var observe : Bool = false
    
    var tasks:[Tasks]=[]
    var projects :[Projects]=[]
    
    var sortStyle :Int = 0
    var sortContent:Int = 0
    
    //var now :Date!
    var minDate :Date!
    var maxDate : Date!

    
    @IBAction func sortContents(_ sender: Any) {
        self.sortContent = self.sc.selectedSegmentIndex
        self.superReload()
    }
    
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
    
    /*
    @IBAction func handleNotificationButton(_ sender: Any) {
        let notificationViewController = self.storyboard?.instantiateViewController(withIdentifier: "Notification") as! NotificationController
        self.navigationController?.pushViewController(notificationViewController, animated: true)
    }
    */
    
    func superReload(){
        let tasksFilter = Const.tasks.filter({$0.chargers[Const.user.id!] != nil})
        let projects = Const.projects.filter({$0.members[Const.user.id!]! >= 1})
        let flag1 = tasksFilter.count == Const.user.tasks.count
        let flag2 = projects.count == Const.user.projects.count
        if flag1 && flag2 {
            self.projects = Const.projects.filter({$0.members[Const.user.id!]! >= 1})
            let taskFilter2 = tasksFilter.filter({$0.status2! < 6})
            switch(self.sortContent){
            case 0:
                if self.sortStyle == 0 {
                    self.tasks = taskFilter2.sorted(by:{$0.startDate! < $1.startDate!})
                }else{
                    self.tasks = taskFilter2.sorted(by:{$0.startDate! > $1.startDate!})
                }
            case 1:
                if self.sortStyle == 0 {
                    self.tasks = taskFilter2.sorted(by:{$0.project! < $1.project! })
                }else{
                    self.tasks = taskFilter2.sorted(by:{$0.project! > $1.project! })
                }
            case 2:
                if self.sortStyle == 0 {
                    self.tasks = taskFilter2.sorted(by:{$0.importance! < $1.importance! })
                }else{
                    self.tasks = taskFilter2.sorted(by:{$0.importance! > $1.importance! })
                }
            default:
                if self.sortStyle == 0 {
                    self.tasks = taskFilter2.sorted(by:{$0.startDate! < $1.startDate!})
                }else{
                    self.tasks = taskFilter2.sorted(by:{$0.startDate! > $1.startDate!})
                }
            }
            
            let now = Date()
            let minTask = self.tasks.sorted(by:{$0.startDate! < $1.startDate! })[0]
            let maxTask = self.tasks.sorted(by:{$0.endDate! > $1.endDate! })[0]
            
            if minTask.startDate! < now {
                self.minDate = minTask.startDate!
            }else{
                self.minDate = now
            }
            
            if maxTask.endDate! > now {
                self.maxDate = minTask.startDate!
            }else{
                self.maxDate = now
            }
            
            self.taskT.reloadData()
            self.dateT.reloadData()
            self.progressT.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.taskT.delegate = self
        self.taskT.dataSource = self
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.taskT.register(nib, forCellReuseIdentifier: "TaskCell")
        self.taskT.rowHeight = 50.0
        self.taskT.sectionHeaderHeight = 50
        
        self.dateT.delegate = self
        self.dateT.dataSource = self
        
        self.progressT.delegate = self
        self.progressT.dataSource = self
        
        let nib2 = UINib(nibName: "DateLabel", bundle: nil)
        self.dateT.register(nib2,forCellWithReuseIdentifier: "DateLabel")
        
        let nib3 = UINib(nibName: "ProgressCell", bundle: nil)
        self.progressT.register(nib3,forCellWithReuseIdentifier: "ProgressCell")
        
        self.badView.adUnitID = "ca-app-pub-2140888928025833/9599348571"
        self.badView.rootViewController = self
        self.badView.load(GADRequest())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool){
        if self.observe == true {
            Database.database().reference().child(Const.TasksPath).removeAllObservers()
            Database.database().reference().child(Const.ProjectsPath).removeAllObservers()
            self.observe = false
        }
        if self.observeUserBool == true {
            Database.database().reference().child(Const.UsersPath).child(Const.user.id!).removeAllObservers()
            self.observeUserBool = false
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT:call viewWillAppear personal task")
        if let user = Auth.auth().currentUser {
            
            let userRef = Database.database().reference().child(Const.UsersPath).child(user.uid)
            if !self.observeUserBool {
                
                userRef.observe(.value,with:{snapshot in
                    let theUser = Users(snapshot)
                    Const.user = theUser
                    Const.addUserData(theUser)
                    
                    if !self.observe {
                        
                        let taskRef = Database.database().reference().child(Const.TasksPath).queryOrdered(byChild:"chargers/" + user.uid).queryEqual(toValue:true)
                        
                        taskRef.observe(.childAdded,with:{snapshot in
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
                        
                        
                        let projectRef = Database.database().reference().child(Const.ProjectsPath).queryOrdered(byChild: "members/" + user.uid ).queryStarting(atValue: 1 )
                        
                        projectRef.observe(.childAdded,with:{snapshot in
                            let theProject = Projects(snapshot)
                            Const.addProjectData(theProject)
                            self.superReload()
                        })
                        
                        projectRef.observe(.childChanged,with:{snapshot in
                            let theProject = Projects(snapshot)
                            Const.reloadProjectData(theProject)
                            self.superReload()
                        })
                        
                        projectRef.observe(.childRemoved,with:{snapshot in
                            let theProject = Projects(snapshot)
                            Const.removeProjectData(theProject)
                            self.superReload()
                        })
                        
                        self.observe = true
                    }
                    
                })
                self.observeUserBool = true
                
            }
        }
    }
}

extension PersonalTaskController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TableViewCell
        cell.type = 1
        cell.setView()
        let red :CGFloat = 157 / 255
        let green :CGFloat = 204 / 255
        let blue :CGFloat = 224 / 255
        let headerView: UIView = cell.contentView
        headerView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let addTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddTask") as! AddTaskController
        let theTask = self.tasks[indexPath.row]
        addTaskViewController.taskId = theTask.id!
        addTaskViewController.projectId = theTask.project!
        let theProject = Const.projects.filter({ $0.id == theTask.project })[0]
        addTaskViewController.isManager = theProject.members[Const.user.id!]! == 2
        addTaskViewController.minDate = theProject.startDate!
        addTaskViewController.maxDate = theProject.endDate!
        self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
}

extension PersonalTaskController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath as IndexPath) as! TableViewCell
        let theTask = self.tasks[indexPath.row]
        cell.type = 1
        cell.setView(task:theTask)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
}


extension PersonalTaskController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

extension PersonalTaskController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 0{
            self.progressT.contentOffset.y = scrollView.contentOffset.y
        }else if scrollView.tag == 1{
            self.progressT.contentOffset.x = scrollView.contentOffset.x
        }else{
            self.dateT.contentOffset.x = scrollView.contentOffset.x
            self.taskT.contentOffset.y = scrollView.contentOffset.y
        }
    }
}


extension PersonalTaskController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.tasks.count > 0{
        /*
        //let now = Date()
        let minTask = self.tasks.sorted(by:{$0.startDate! < $1.startDate! })[0]
        let maxTask = self.tasks.sorted(by:{$0.endDate! > $1.endDate! })[0]
        var minDate :Date!
        var maxDate : Date!
            
        if minTask.startDate! < self.now {
            minDate = minTask.startDate!
        }else{
            minDate = self.now
        }
         
        if maxTask.endDate! > self.now {
            maxDate = minTask.startDate!
        }else{
            maxDate = self.now
        }
        */
            
        return Const.getTermOfTwoDate(self.minDate,self.maxDate)
        } else {
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.restorationIdentifier == "dateT" {
            return 1
        } else {
            return self.tasks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let minTask = self.tasks.sorted(by:{$0.startDate! < $1.startDate! })[0]
        //let now = Date()
        /*
        var minDate :Date!
        
        if minTask.startDate! < self.now {
            minDate = minTask.startDate!
        }else{
            minDate = self.now
        }
         */
        if collectionView.restorationIdentifier == "dateT" {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateLabel",for: indexPath as IndexPath) as! DateLabel
            cell.setDayLabel(self.minDate,indexPath.item)
            return cell
            
        } else {
            //print("DEBUG_PRINT:section-item:\(indexPath.section)-\(indexPath.item)")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressCell",for: indexPath as IndexPath) as! ProgressCell
            let theTask = self.tasks[indexPath.section]
            cell.setProgress(self.minDate,theTask,indexPath.item)
            
            let flag = theTask.status2! != 0 && theTask.status2! != 4 && theTask.status2! != 6 && theTask.status2! != 2
            let theProject = Const.projects.filter({ $0.id == theTask.project })[0]
            let flag0 = theProject.members[Const.user.id!]! == 2
            if flag0 || flag {
                cell.isUserInteractionEnabled = true
            } else{
                cell.isUserInteractionEnabled = false
            }
            
            return cell
        }
    }
}

extension PersonalTaskController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PopUp(nibName: "PopUp", bundle: nil)
        let theTask = self.tasks[indexPath.section]
        vc.task = theTask
        let theProject = Const.projects.filter({$0.id == theTask.project })[0]
        vc.isManager = theProject.members[Const.user.id!]! == 2
        let pop = PopupDialog(viewController: vc)
        present(pop, animated: true, completion: nil)
    }
    
}

