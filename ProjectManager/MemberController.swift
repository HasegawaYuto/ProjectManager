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
    
    var memberIds : [String]=[]
    var memberType : [String:Bool]=[:]
    var memberNames : [String:String]=[:]
    var buttonLabel:String!
    
    @IBOutlet weak var memberT: UITableView!
    @IBOutlet weak var addMemberButton: UIBarButtonItem!
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        let setPath = Const.ProjectsPath + "/" + self.projectId + "/members"
        Database.database().reference().child(setPath).removeAllObservers()
        for uid in self.memberIds {
            Database.database().reference().child(Const.UsersPath).child(uid).child("name").removeAllObservers()
        }
        self.memberIds = []
        self.memberType = [:]
        self.memberNames = [:]
        self.memberT.reloadData()
        self.observe = false
        //print("DEBUG_PRINT:call viewWillDisappear")
    }

    @IBAction func handleInviteButton(_ sender: Any) {
        let inviteViewController = self.storyboard?.instantiateViewController(withIdentifier: "Invite") as? InviteMemberController
        inviteViewController?.projectId = self.projectId
        navigationController?.pushViewController(inviteViewController!, animated: true)
        //print("DEBUG_PRINT:push Invite")
    }
    
    func superReload(){
        let flag1 = self.memberIds.count == self.memberNames.count
        let flag2 = self.memberIds.count == self.memberType.count
        if flag1 && flag2 {
            self.memberT.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isManager {
            self.addMemberButton.isEnabled = false
        }
        
        if self.observe == false {
            let setPath = Const.ProjectsPath + "/" + self.projectId + "/members"
            let memberDataRef = Database.database().reference().child(setPath)
            memberDataRef.observe(.childAdded,with:{snapshot in
                let userBool = IdBool(booldata:snapshot)
                let userId = userBool.id!
                self.memberType[userId] = userBool.bool
                let userDataRef = Database.database().reference().child(Const.UsersPath).child(userId)
                userDataRef.observe(.value,with:{snapshot in
                    let userData = Users(userdata:snapshot)
                    self.memberNames[userId] = userData.name!
                    self.memberIds.insert( userId , at:0)
                    self.superReload()
                })
            })
            
            memberDataRef.observe(.childRemoved,with:{snapshot in
                let userBool = IdBool(booldata:snapshot)
                let index = self.memberIds.index(of:userBool.id!)
                self.memberIds.remove(at:index!)
                self.memberNames.removeValue(forKey:userBool.id!)
                self.memberType.removeValue(forKey:userBool.id!)
                Database.database().reference().child(Const.UsersPath).child(userBool.id!).removeAllObservers()
                self.superReload()
            })
            
            memberDataRef.observe(.childChanged,with:{snapshot in
                let userBool = IdBool(booldata:snapshot)
                self.memberType[userBool.id!] = userBool.bool
                self.superReload()
            })
            
            self.observe = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberIds.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //print("DEBUG_PRINT:set cell action処理")
        let memberId = self.memberIds[indexPath.row]
        let memberBool = self.memberType[memberId]
        if !memberBool! {
            self.buttonLabel = "To Manager"
        }else{
            self.buttonLabel = "To Joinner"
        }
        let typeButton = UITableViewRowAction(style: .normal, title: self.buttonLabel) { (action, index) -> Void in
            let setPath = Const.ProjectsPath + "/" + self.projectId + "/members/" + memberId
            let userPath = Const.UsersPath + "/" + memberId + "/projects/" + self.projectId
            let memberDataRef = Database.database().reference().child(setPath)
            let userDataRef = Database.database().reference().child(userPath)
            if memberBool! {
                memberDataRef.setValue(false)
                userDataRef.setValue(false)
            }else{
                memberDataRef.setValue(true)
                userDataRef.setValue(true)
            }
        }
        if !memberBool! {
            typeButton.backgroundColor = UIColor.yellow
            //typeButton.textColor = UIColor.black
        }else{
            typeButton.backgroundColor = UIColor.clear
        }
        
        let excludeButton = UITableViewRowAction(style: .normal, title: "exclude") { (action, index) -> Void in
            let setPath = Const.ProjectsPath + "/" + self.projectId + "/members/" + memberId
            let userPath = Const.UsersPath + "/" + memberId + "/projects/" + self.projectId
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
        //print("DEBUG_PRINT:call cellForRowAt")
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath as IndexPath)
        let memberId = self.memberIds[indexPath.row]
        let memberName = self.memberNames[memberId]
        let memberBool = self.memberType[memberId]
        cell.textLabel?.text = memberName
        if memberBool! {
            cell.backgroundColor = UIColor.yellow
        }else{
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
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
