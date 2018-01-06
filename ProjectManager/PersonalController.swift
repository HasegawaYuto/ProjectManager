//
//  PersonalController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/04.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PersonalController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var sc: UISegmentedControl!
    @IBOutlet weak var tableV: UITableView!
    
    var setPath :String?
    //var projectId : String?
    var observeUserBool:Bool = false
    var observeProjectBool:Bool = false
    //var observeInvitedBool:Bool = false
    //var projectsIds : [String] = []
    var selectProjects:[Projects]=[]
    var projectType : Int = 0
    //var theProjectId : String!
    
    //var projects:[String:Projects]=[:]

    var enterButton: UITableViewRowAction!
    var detailButton: UITableViewRowAction!
    var leaveButton: UITableViewRowAction!
    var refuseButton: UITableViewRowAction!

    @IBAction func handleLogOut(_ sender: Any) {
        print("DEBUG_PRINT:call log out")
        if self.observeUserBool {
            Database.database().reference().child(Const.UsersPath).child(Const.user.id!).removeAllObservers()
            self.observeUserBool = false
        }
        if self.observeProjectBool {
            Database.database().reference().child(Const.ProjectsPath).removeAllObservers()
            Database.database().reference().child(Const.TasksPath).removeAllObservers()
            self.observeProjectBool = false
        }
        try! Auth.auth().signOut()
        self.selectProjects = []
        Const.projects = []
        Const.tasks = []
        Const.users = []
        self.sc.selectedSegmentIndex = 0
        self.tableV.reloadData()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        Const.user = nil
        self.present(loginViewController!, animated: true, completion: nil)
    }
    
    @IBAction func handleCreateProjectButton(_ sender: Any) {
        let createProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! CreateProjectController
        createProjectViewController.isManager = true
        navigationController?.pushViewController(createProjectViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTF.delegate = self
        self.tableV.delegate = self
        self.tableV.dataSource = self
        //print("DEBUG_PRINT:call viewDidload personal")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if Auth.auth().currentUser != nil {
            Database.database().reference().child(Const.UsersPath).child(Const.user.id!).removeAllObservers()
            Database.database().reference().child(Const.ProjectsPath).removeAllObservers()
            self.observeUserBool = false
            self.observeProjectBool = false
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:personal viewWillAppear")
        super.viewWillAppear(animated)
        if let user = Auth.auth().currentUser {
            let userRef = Database.database().reference().child(Const.UsersPath).child(user.uid)
            
            if !self.observeUserBool {
                
                userRef.observe(.value,with:{snapshot in
                    let theUser = Users(snapshot)
                    Const.user = theUser
                    Const.addUserData(theUser)
                    
                    if self.userNameTF.text != Const.user.name! {
                        self.userNameTF.text = Const.user.name!
                    }
                    
                    
                    if !self.observeProjectBool {
                        let projectRef = Database.database().reference().child(Const.ProjectsPath).queryOrdered(byChild: "members/" + user.uid).queryStarting(atValue: 0)
                        
                        
                        projectRef.observe(.childAdded,with:{snapshot in
                            let theProject = Projects(snapshot)
                            Const.addProjectData(theProject)
                            self.tableV.reloadData()
                        })
                        
                        projectRef.observe(.childChanged,with:{snapshot in
                            let theProject = Projects(snapshot)
                            Const.reloadProjectData(theProject)
                            self.tableV.reloadData()
                        })
                        
                        
                        projectRef.observe(.childRemoved,with:{snapshot in
                            let theProject = Projects(snapshot)
                            Const.removeProjectData(theProject)
                            
                            let taskFilter = Const.tasks.filter({$0.project == theProject.id!})
                            if taskFilter.count > 0{
                                for task in taskFilter {
                                    Const.removeTaskData(task)
                                }
                            }
                            
                            self.tableV.reloadData()
                        })
                        
                        self.observeProjectBool = true
                    }
                })
                self.observeUserBool = true
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.setPath = Const.UsersPath + "/" + Const.user.id! + "/name"
        let postRef = Database.database().reference().child(self.setPath!)
        postRef.setValue(self.userNameTF.text!)
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func handleSegmentControl(_ sender: Any) {
        self.projectType = sc.selectedSegmentIndex
        self.tableV.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(self.projectType){
            case 0:
                self.selectProjects = Const.projects.filter{ $0.members[Const.user.id!]! > 0 }
            case 1:
                self.selectProjects = Const.projects.filter{ $0.members[Const.user.id!]! == 2 }
            case 2:
                self.selectProjects = Const.projects.filter{ $0.members[Const.user.id!]! == 1 }
            case 3:
                self.selectProjects = Const.projects.filter{ $0.members[Const.user.id!]! == 0 }
            default:
                self.selectProjects = Const.projects.filter{ $0.members[Const.user.id!]! > 0 }
            }
        return self.selectProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        if self.selectProjects[indexPath.row].title != "" {
            cell.textLabel?.text = self.selectProjects[indexPath.row].title!
        } else {
            cell.textLabel?.text = "No Project Title"
        }
        cell.textLabel?.textAlignment = NSTextAlignment.center
        return cell
    }
    

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableV.deselectRow(at: indexPath as IndexPath, animated: true)
        if self.projectType < 3 {
            let projectTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectTask") as! ProjectTaskController
            projectTaskViewController.projectId = self.selectProjects[indexPath.row].id!
            self.navigationController?.pushViewController(projectTaskViewController, animated: true)
            }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let projectId = self.selectProjects[indexPath.row].id!
        self.detailButton = UITableViewRowAction(style: .normal, title: "Detail") { (action, index) -> Void in
            let createProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! CreateProjectController
            createProjectViewController.projectId = projectId
            self.navigationController?.pushViewController(createProjectViewController, animated: true)
        }
        self.detailButton.backgroundColor = UIColor.green
        
        
        self.leaveButton = UITableViewRowAction(style: .normal, title: "Leave") { (action, index) -> Void in

            let onlyMember = self.selectProjects[indexPath.row].members.count == 1
            
            
            let path1 = Const.ProjectsPath + "/" + projectId + "/members/" + Const.user.id!
            let projectUserRef = Database.database().reference().child(path1)
            projectUserRef.removeValue()
            
            let path2 = Const.UsersPath + "/" + Const.user.id! + "/projects/" + projectId
            let userProjectsRef = Database.database().reference().child(path2)
            userProjectsRef.removeValue()
            
            var taskids :[String]=[]
            for taskid in self.selectProjects[indexPath.row].tasks.keys {
                for taskid2 in Const.user.tasks.keys {
                    if taskid == taskid2 {
                        Database.database().reference().child(Const.UsersPath + "/" + Const.user.id! + "/tasks/" + taskid).removeValue()
                        taskids.append(taskid)
                    }
                }
            }
            
            
            if onlyMember {
                for taskid in self.selectProjects[indexPath.row].tasks.keys {
                    Database.database().reference().child(Const.TasksPath).child(taskid).removeValue()
                }
                Database.database().reference().child(Const.ProjectsPath).child(projectId).removeValue()
            }
        }
        self.leaveButton.backgroundColor = UIColor.red
        
        
        
        self.refuseButton = UITableViewRowAction(style: .normal, title: "Refuse") { (action, index) -> Void in
            
            let path1 = Const.ProjectsPath + "/" + projectId + "/members/" + Const.user.id!
            let projectRef = Database.database().reference().child(path1)
            
            let path2 = Const.UsersPath + "/" + Const.user.id! + "/projects/" + projectId
            let userProjectsRef = Database.database().reference().child(path2)
            
            projectRef.removeValue()
            userProjectsRef.removeValue()
        }
        self.refuseButton.backgroundColor = UIColor.red
        
        
        
        
        self.enterButton = UITableViewRowAction(style: .normal, title: "Join") { (action, index) -> Void in
            let path1 = Const.ProjectsPath + "/" + projectId + "/members/" + Const.user.id!
            let projectRef = Database.database().reference().child(path1)
            
            let path2 = Const.UsersPath + "/" + Const.user.id! + "/projects/" + projectId
            let userProjectsRef = Database.database().reference().child(path2)
            
            projectRef.setValue(1)
            userProjectsRef.setValue(1)
        }
        self.enterButton.backgroundColor = UIColor.blue
        
        
        if self.projectType < 3 {
            return [leaveButton,detailButton]
        }else{
            return [refuseButton,enterButton,detailButton]
        }
    }
    
    
}
