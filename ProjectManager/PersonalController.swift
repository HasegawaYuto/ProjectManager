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
    var user : Users!
    var observeBool:Bool = false
    var projectsIds : [String] = []
    var manageProjectsIds : [String] = []
    var joinProjectsIds : [String] = []
    var invitedProjectsIds : [String] = []
    var projectTitles : [String:String]=[:]
    var projectType : Int = 0
    var theProjectId : String!

    @IBAction func handleLogOut(_ sender: Any) {
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTF.delegate = self
        self.tableV.delegate = self
        self.tableV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT:call viewWillAppear")
        
        if !self.observeBool {
            print("DEBUG_PRINT:set observer")
            self.setPath = Const.UsersPath + "/" + (Auth.auth().currentUser?.uid)!
            let userNameRef = Database.database().reference().child(self.setPath!)
            userNameRef.child("name").observe( .value , with : { snapshot in
                //print("DEBUG_PRINT:get Users")
                //self.user = Users( userdata : snapshot )
                self.userNameTF.text = snapshot.value as? String
            })
            
            let projectIdRef = Database.database().reference().child(self.setPath!)
            projectIdRef.child("projects").observe( .childAdded , with:{ snapshot in
                //print("DEBUG_PRINT:.childAdded user->projects")
                if let bool = snapshot.value as? Bool{
                    let pid = snapshot.key
                    self.projectsIds.insert(pid ,at:0)
                    //print("DEBUG_PRINT:set projectsIds:\(self.projectsIds.count)")
                    if bool {
                        self.manageProjectsIds.insert(pid ,at:0)
                        //print("DEBUG_PRINT:\(pid) :true")
                        //print("DEBUG_PRINT:Manage:\(self.manageProjectsIds.count)")
                    }else{
                        self.joinProjectsIds.insert(pid ,at:0)
                        //print("DEBUG_PRINT:\(pid) :false")
                        //print("DEBUG_PRINT:Join:\(self.joinProjectsIds.count)")
                    }
                    //print("DEBUG_PRINT:Projects:\(self.projectsIds.count)")
                    self.setPath = Const.ProjectsPath + "/" + pid + "/title"
                    let projectTitleRef = Database.database().reference().child(self.setPath!)
                    projectTitleRef.observe(.value,with:{snapshot in
                        self.projectTitles[pid] = snapshot.value as? String
                        //print("DEBUG_PRINT:.value :\(self.projectTitles)")
                        if self.projectsIds.count == self.projectTitles.count{
                            self.tableV.reloadData()
                        }
                        //print("DEBUG_PRINT:projectTitleにaddしたよ")
                    })
                    //self.tableV.reloadData()
                }
            })
            projectIdRef.child("projects").observe( .childChanged , with:{ snapshot in
                //print("DEBUG_PRINT:.childChanged user->projects")
                if let bool = snapshot.value as? Bool{
                    let pid = snapshot.key
                    if bool {
                        let index = self.joinProjectsIds.index(of: pid)
                        self.joinProjectsIds.remove(at: index!)
                        self.manageProjectsIds.insert(pid ,at:0)
                        //print("DEBUG_PRINT:\(pid) :false->true")
                    }else{
                        let index = self.manageProjectsIds.index(of: pid)
                        self.manageProjectsIds.remove(at: index!)
                        self.joinProjectsIds.insert(pid ,at:0)
                        //print("DEBUG_PRINT:\(pid) :true->false")
                    }
                    self.tableV.reloadData()
                }
            })
            projectIdRef.child("invited").observe( .childAdded , with:{ snapshot in
                self.invitedProjectsIds.insert( snapshot.value as! String, at:0)
                self.tableV.reloadData()
            })
            projectIdRef.child("invited").observe( .childRemoved , with:{ snapshot in
                //self.invitedProjectsIds.insert( snapshot.value as! String, at:0)
                let index = self.invitedProjectsIds.index(of : snapshot.value as! String)
                self.invitedProjectsIds.remove(at: index!)
                self.tableV.reloadData()
            })
            self.observeBool = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("DEBUG_PRINT:textFieldDidEndEditing")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("DEBUG_PRINT:pushエンター")
        
        self.setPath = Const.UsersPath + "/" + (Auth.auth().currentUser?.uid)!
        let postRef = Database.database().reference().child(self.setPath!)
        let updateData = ["name":self.userNameTF.text!]
        postRef.updateChildValues(updateData)
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        print("DEBUG_PRINT:キーボードしまう")
        return true
    }
    
    @IBAction func handleSegmentControl(_ sender: Any) {
        self.projectType = sc.selectedSegmentIndex
        self.tableV.reloadData()
        print("DEBUG_PRINT:set projectType:\(self.projectType)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("DEBUG_PRINT:call numberOfRowsInSection")
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
        //print("DEBUG_PRINT:projectTitles.count:\(self.projectTitles.count)")
        //return self.projectTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT:call cellForRowAt")
        // セルを取得してデータを設定する
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
        default:
            self.theProjectId = self.projectsIds[indexPath.row]
        }
        let theProjectTitle :String = self.projectTitles[self.theProjectId!]!
        cell.textLabel?.text = theProjectTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableV.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
}
