//
//  MemberController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/05.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MemberController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var projectId: String!
    var isManager: Bool = false
    var observe: Bool = false
    
    var buttonLabel:String!
    var sortUsers:[Users]=[]
    
    @IBOutlet weak var memberT: UITableView!
    @IBOutlet weak var addMemberButton: UIBarButtonItem!
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        Database.database().reference().child(Const.UsersPath).removeAllObservers()
        self.observe = false
        print("DEBUG_PRINT:[member] call viewWillDisappear")
    }

    @IBAction func handleInviteButton(_ sender: Any) {
        let inviteViewController = self.storyboard?.instantiateViewController(withIdentifier: "Invite") as? InviteMemberController
        inviteViewController?.projectId = self.projectId
        navigationController?.pushViewController(inviteViewController!, animated: true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT:will appear members")
        if !isManager {
            self.addMemberButton.isEnabled = false
        }
        
        

        if self.observe == false {
            
            let memberDataRef = Database.database().reference().child(Const.UsersPath).queryOrdered(byChild: "projects/" + self.projectId).queryStarting(atValue:1)
            
            print("DEBUG_PRINT:[member] set memberDataRef")
            
            memberDataRef.observe(.childAdded,with:{snapshot in
                print("DEBUG_PRINT:[member] call add")
                let theUser = Users(snapshot)
                Const.addUserData(theUser)
                self.memberT.reloadData()
            })
            
            memberDataRef.observe(.childChanged,with:{snapshot in
                print("DEBUG_PRINT:[member] call change")
                let theUser = Users(snapshot)
                Const.reloadUserData(theUser)
                self.memberT.reloadData()
            })
            
            memberDataRef.observe(.childRemoved,with:{snapshot in
                print("DEBUG_PRINT:[member] call remove")
                let theUser = Users(snapshot)
                Const.removeUserData(theUser)
                self.memberT.reloadData()
            })
            
            self.observe = true
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT:[member] Const.users:\(Const.users.count)")
        let tempUsers = Const.users.filter({$0.projects[self.projectId!]! >= 1 })
        print("DEBUG_PRINT:[member] tempUsers:\(tempUsers)")
        self.sortUsers = tempUsers.sorted(by:{$0.projects[self.projectId!]! > $1.projects[self.projectId!]!})
        print("DEBUG_PRINT:[member] self.sortUsers.count:\(self.sortUsers.count)")
        return self.sortUsers.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let theMember = self.sortUsers[indexPath.row]
        let flag = theMember.projects[self.projectId]! == 1
        if flag {
            self.buttonLabel = "To Manager"
        }else{
            self.buttonLabel = "To Joinner"
        }
        let typeButton = UITableViewRowAction(style: .normal, title: self.buttonLabel) { (action, index) -> Void in
            let setPath = Const.ProjectsPath + "/" + self.projectId + "/members/" + theMember.id!
            let userPath = Const.UsersPath + "/" + theMember.id! + "/projects/" + self.projectId
            let memberDataRef = Database.database().reference().child(setPath)
            let userDataRef = Database.database().reference().child(userPath)
            if !flag {
                memberDataRef.setValue(1)
                userDataRef.setValue(1)
            }else{
                memberDataRef.setValue(2)
                userDataRef.setValue(2)
            }
        }
        if !flag {
            typeButton.backgroundColor = UIColor.yellow
            //typeButton.textColor = UIColor.black
        }else{
            typeButton.backgroundColor = UIColor.clear
        }
        
        let excludeButton = UITableViewRowAction(style: .normal, title: "exclude") { (action, index) -> Void in
            let setPath = Const.ProjectsPath + "/" + self.projectId + "/members/" + theMember.id!
            let userPath = Const.UsersPath + "/" + theMember.id! + "/projects/" + self.projectId
            let memberDataRef = Database.database().reference().child(setPath)
            let userDataRef = Database.database().reference().child(userPath)
            memberDataRef.removeValue()
            userDataRef.removeValue()
            print("DEBUG_PRINT:exclude")
        }
        excludeButton.backgroundColor = UIColor.red
        
        if self.isManager {
            return [excludeButton,typeButton]
        }else{
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT:[member] call cellForRowAt")
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath as IndexPath)
        let theMember = self.sortUsers[indexPath.row]
        let flag = theMember.projects[self.projectId]! == 1
        cell.textLabel?.text = theMember.name
        if !flag {
            cell.backgroundColor = UIColor.yellow
        }else{
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.memberT.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memberT.delegate = self
        self.memberT.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
