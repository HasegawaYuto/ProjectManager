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
    
    //let user = Auth.auth().currentUser!
    var setPath :String?
    var projectId : String?
    var observeUserBool:Bool = false
    var observeProjectBool:Bool = false
    var observeInvitedBool:Bool = false
    var projectsIds : [String] = []
    var manageProjectsIds : [String] = []
    var joinProjectsIds : [String] = []
    var invitedProjectsIds : [String] = []
    var projectTitles : [String:String]=[:]
    var projectType : Int = 0
    var theProjectId : String!
    var theProjectTitle : String!
    
    var projects:[String:Projects]=[:]
    var userId :String!

    var enterButton: UITableViewRowAction!
    var detailButton: UITableViewRowAction!
    var leaveButton: UITableViewRowAction!
    var refuseButton: UITableViewRowAction!

    @IBAction func handleLogOut(_ sender: Any) {
        self.setPath = Const.UsersPath + "/" + self.userId!
        print("DEBUG_PRINT:call log out")
        if self.observeUserBool {
            Database.database().reference().child(self.setPath!).child("name").removeAllObservers()
            print("DEBUG_PRINT:remove observer name")
            self.observeUserBool = false
        }
        if self.observeProjectBool {
            Database.database().reference().child(self.setPath!).child("projects").removeAllObservers()
            print("DEBUG_PRINT:remove observer projects")
            for pid in self.projectsIds {
                Database.database().reference().child(Const.ProjectsPath).child(pid).child("title").removeAllObservers()
                print("DEBUG_PRINT:remove observer projects(\(pid)) title")
            }
            
            self.projectsIds = []
            self.manageProjectsIds = []
            self.joinProjectsIds = []
            self.observeProjectBool = false
        }
        if self.observeInvitedBool {
            Database.database().reference().child(self.setPath!).child("invited").removeAllObservers()
            print("DEBUG_PRINT:remove observer invited")
            self.invitedProjectsIds = []
            self.observeInvitedBool = false
            for pid in self.invitedProjectsIds {
                Database.database().reference().child(Const.ProjectsPath).child(pid).child("title").removeAllObservers()
                print("DEBUG_PRINT:remove observer projects(\(pid)) title")
            }
        }
        self.projectTitles = [:]
        self.sc.selectedSegmentIndex = 0
        self.tableV.reloadData()
        
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
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
        print("DEBUG_PRINT:call viewDidload personal")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT:call viewWillAppear personal")
        if let user = Auth.auth().currentUser {
            self.userId = user.uid
            ///////////  user名を取得
            if !self.observeUserBool {
                self.setPath = Const.UsersPath + "/" + self.userId!
                let userNameRef = Database.database().reference().child(self.setPath!)
                userNameRef.observeSingleEvent(of: .value , with : { snapshot in
                    if snapshot.value != nil {
                        let theUser = Users(userdata:snapshot)
                        self.userNameTF.text = theUser.name!
                    }
                })
                self.observeUserBool = true
            }
            
            /////////////   プロジェクト名を取得
            let projectIdRef = Database.database().reference().child(self.setPath!)
            /////////  user->projects
            if !self.observeProjectBool {
                /////////   childAdded
                projectIdRef.child("projects").observe( .childAdded , with:{ snapshot in
                    let projectBool = IdBool(booldata:snapshot)
                    if let bool = projectBool.bool , let pid = projectBool.id{
                        if bool {
                            self.manageProjectsIds.insert(pid ,at:0)
                        }else{
                            self.joinProjectsIds.insert(pid ,at:0)
                        }
                        self.projectsIds.insert(pid ,at:0)
                        let setNewPath = Const.ProjectsPath + "/" + pid
                        let projectTitleRef = Database.database().reference().child(setNewPath)
                        projectTitleRef.observe(.value,with:{snapshot in
                            let projectData = Projects(projectdata:snapshot)
                            self.projectTitles[pid] = projectData.title
                            self.superReload()
                        })
                    }
                })
                
                /////////   childChanged
                projectIdRef.child("projects").observe( .childChanged , with:{ snapshot in
                    let projectBool = IdBool(booldata:snapshot)
                    if let bool = projectBool.bool , let pid = projectBool.id{
                        if bool {
                            let index = self.joinProjectsIds.index(of: pid)
                            self.joinProjectsIds.remove(at: index!)
                            self.manageProjectsIds.insert(pid ,at:0)
                        }else{
                            let index = self.manageProjectsIds.index(of: pid)
                            self.manageProjectsIds.remove(at: index!)
                            self.joinProjectsIds.insert(pid ,at:0)
                        }
                        self.superReload()
                    }
                })
                
                /////////   childRemoved
                projectIdRef.child("projects").observe( .childRemoved , with:{ snapshot in
                    let projectBool = IdBool(booldata:snapshot)
                    if let bool = projectBool.bool , let pid = projectBool.id{
                        let indexA = self.projectsIds.index(of: pid)
                        self.projectsIds.remove(at: indexA!)
                        self.projectTitles.removeValue(forKey: pid)
                        if !bool {
                            let index = self.joinProjectsIds.index(of: pid)
                            self.joinProjectsIds.remove(at: index!)
                        }else{
                            let index = self.manageProjectsIds.index(of: pid)
                            self.manageProjectsIds.remove(at: index!)
                        }
                        let setNewPath = Const.ProjectsPath + "/" + pid
                        let projectTitleRef = Database.database().reference().child(setNewPath)
                        projectTitleRef.removeAllObservers()
                        self.superReload()
                    }
                })
                
                self.observeProjectBool = true
            }
            
            
            /////////  user->invited
            if !self.observeInvitedBool {
                
                /////////   childAdded
                projectIdRef.child("invited").observe( .childAdded , with:{ snapshot in
                    let pid = IdBool(booldata:snapshot).id!
                    let setNewPath = Const.ProjectsPath + "/" + pid
                    let projectTitleRef = Database.database().reference().child(setNewPath)
                    projectTitleRef.observe(.value,with:{snapshot in
                        let projectData = Projects(projectdata:snapshot)
                        self.invitedProjectsIds.append( pid )
                        self.projectTitles[pid] = projectData.title!
                        self.superReload()
                    })
                })
                
                /////////   childRemoved
                projectIdRef.child("invited").observe( .childRemoved , with:{ snapshot in
                    let pid = IdBool(booldata:snapshot).id!
                    let index = self.invitedProjectsIds.index(of: pid)
                    self.invitedProjectsIds.remove(at: index!)
                    self.projectTitles.removeValue(forKey: pid)
                    let setNewPath = Const.ProjectsPath + "/" + pid
                    let projectTitleRef = Database.database().reference().child(setNewPath)
                    projectTitleRef.removeAllObservers()
                    self.superReload()
                })
                
                self.observeInvitedBool = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.setPath = Const.UsersPath + "/" + (Auth.auth().currentUser?.uid)!
        let postRef = Database.database().reference().child(self.setPath!)
        let updateData = ["name":self.userNameTF.text!]
        postRef.updateChildValues(updateData)
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func handleSegmentControl(_ sender: Any) {
        self.projectType = sc.selectedSegmentIndex
        self.superReload()
    }
    
    
    func superReload(){
        let sum = self.manageProjectsIds.count + self.joinProjectsIds.count + self.invitedProjectsIds.count
        if self.projectTitles.count == sum {
            self.tableV.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(self.projectType){
            case 0:
                return self.projectsIds.count
            case 1:
                return self.manageProjectsIds.count
            case 2:
                return self.joinProjectsIds.count
            case 3:
                return self.invitedProjectsIds.count
            default:
                return self.projectsIds.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        switch(self.projectType){
        case 0:
            self.theProjectId = self.projectsIds[indexPath.row]
        case 1:
            self.theProjectId = self.manageProjectsIds[indexPath.row]
        case 2:
            self.theProjectId = self.joinProjectsIds[indexPath.row]
        case 3:
            self.theProjectId = self.invitedProjectsIds[indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        default:
            self.theProjectId = self.projectsIds[indexPath.row]
        }
        self.theProjectTitle = self.projectTitles[self.theProjectId!]!
        cell.textLabel?.text = self.theProjectTitle
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.backgroundColor = UIColor.yellow
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableV.deselectRow(at: indexPath as IndexPath, animated: true)
        if self.projectType < 3 {
            switch(self.projectType){
            case 0:
                self.theProjectId = self.projectsIds[indexPath.row]
            case 1:
                self.theProjectId = self.manageProjectsIds[indexPath.row]
            case 2:
                self.theProjectId = self.joinProjectsIds[indexPath.row]
            default:
                self.theProjectId = self.projectsIds[indexPath.row]
            }
            let projectTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectTask") as! ProjectTaskController
            projectTaskViewController.projectId = self.theProjectId!
            self.navigationController?.pushViewController(projectTaskViewController, animated: true)
            }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch(self.projectType){
            case 0:
                self.theProjectId = self.projectsIds[indexPath.row]
            case 1:
                self.theProjectId = self.manageProjectsIds[indexPath.row]
            case 2:
                self.theProjectId = self.joinProjectsIds[indexPath.row]
            case 3:
                self.theProjectId = self.invitedProjectsIds[indexPath.row]
            default:
                self.theProjectId = self.projectsIds[indexPath.row]
        }
        
        
        self.detailButton = UITableViewRowAction(style: .normal, title: "Detail") { (action, index) -> Void in
            let createProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! CreateProjectController
            createProjectViewController.projectId = self.theProjectId!
            self.navigationController?.pushViewController(createProjectViewController, animated: true)
        }
        self.detailButton.backgroundColor = UIColor.green
        
        
        let projectUserPath = Const.ProjectsPath + "/" + self.theProjectId + "/members/" + Auth.auth().currentUser!.uid
        let userTaskPath = Const.UsersPath + "/" + Auth.auth().currentUser!.uid + "/tasks"
        let projectTaskPath = Const.ProjectsPath + "/" + self.theProjectId + "/tasks"
        let userProjectsPath = Const.UsersPath + "/" + Auth.auth().currentUser!.uid + "/projects/" + self.theProjectId
        let userInvitedPath = Const.UsersPath + "/" + Auth.auth().currentUser!.uid + "/invited/" + self.theProjectId
        
        self.leaveButton = UITableViewRowAction(style: .normal, title: "Leave") { (action, index) -> Void in
            let projectUserRef = Database.database().reference().child(projectUserPath)
            projectUserRef.removeValue()
            let userProjectsRef = Database.database().reference().child(userProjectsPath)
            userProjectsRef.removeValue()
            
            let projectTaskRef = Database.database().reference().child(projectTaskPath)
            projectTaskRef.observeSingleEvent(of:.value,with:{snapshot in
                if let theTaskId = IdValue(valuedata:snapshot).id{
                    let userTheTaskPath = userTaskPath + "/" + theTaskId
                    let userTheTaskRef = Database.database().reference().child(userTheTaskPath)
                    userTheTaskRef.observeSingleEvent(of:.value,with:{snapshot in
                        if let userTheTaskId = IdValue(valuedata:snapshot).id {
                            let userTheTaskIdPath = userTaskPath + "/" + userTheTaskId
                            let userTheTaskIdRef = Database.database().reference().child(userTheTaskIdPath)
                            userTheTaskIdRef.removeValue()
                        }
                    })
                }
            })
            let projectPath = Const.ProjectsPath + "/" + self.theProjectId
            let projectRef = Database.database().reference().child(projectPath)
            projectRef.removeAllObservers()
        }
        self.leaveButton.backgroundColor = UIColor.red
        
        
        
        self.refuseButton = UITableViewRowAction(style: .normal, title: "Refuse") { (action, index) -> Void in
            let userInvitedRef = Database.database().reference().child(userInvitedPath)
            userInvitedRef.removeValue()
        }
        self.refuseButton.backgroundColor = UIColor.red
        
        
        
        
        self.enterButton = UITableViewRowAction(style: .normal, title: "Join") { (action, index) -> Void in
            let projectRef = Database.database().reference().child(projectUserPath)
            let userProjectsRef = Database.database().reference().child(userProjectsPath)
            let userInvitedRef = Database.database().reference().child(userInvitedPath)
            
            userInvitedRef.removeValue()
            projectRef.setValue(false)
            userProjectsRef.setValue(false)
        }
        self.enterButton.backgroundColor = UIColor.blue
        
        
        if self.projectType < 3 {
            return [leaveButton,detailButton]
        }else{
            return [refuseButton,enterButton,detailButton]
        }
    }
    
    
}
