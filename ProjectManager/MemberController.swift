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

    @IBAction func handleInviteButton(_ sender: Any) {
        let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "Invite")
        navigationController?.pushViewController(memberViewController!, animated: true)
        print("DEBUG_PRINT:push Invite")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("DEBUG_PRINT:\(self.projectId):\(self.isManager)")
        if !isManager {
            self.addMemberButton.isEnabled = false
        }
        
        if self.observe == false {
            //print("DEBUG_PRINT:set observe")
            let setPath = Const.ProjectsPath + "/" + self.projectId + "/members"
            let memberDataRef = Database.database().reference().child(setPath)
            memberDataRef.observe(.childAdded,with:{snapshot in
                //print("DEBUG_PRINT:childAdded")
                let userId = snapshot.key
                self.memberIds.insert( userId , at:0)
                self.memberType[userId] = snapshot.value as? Bool
                let userDataRef = Database.database().reference().child(Const.UsersPath).child(snapshot.key)
                userDataRef.child("name").observe(.value,with:{snapshot in
                    self.memberNames[userId] = snapshot.value as? String
                    //print("DEBUG_PRINT:memberName:\(self.memberNames.count)")
                    if self.memberIds.count <= self.memberNames.count {
                        self.memberT.reloadData()
                        //print("DEBUG_PRINT:reload")
                    }
                })
                //print("DEBUG_PRINT:memberIds:\(self.memberIds.count)")
            })
            memberDataRef.observe(.childChanged,with:{snapshot in
                self.memberType[snapshot.key] = snapshot.value as? Bool
                //print("DEBUG_PRINT:memberType:\(snapshot.key)->\(snapshot.value as! String)")
            })
            self.observe = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberNames.count
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
            //let createProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! CreateProjectController
            //createProjectViewController.projectId = self.theProjectId!
            //self.navigationController?.pushViewController(createProjectViewController, animated: true)
            //self.array.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            //print("DEBUG_PRINT:\(self.theProjectId!):detail処理")
        }
        if !memberBool! {
            typeButton.backgroundColor = UIColor.yellow
        }else{
            typeButton.backgroundColor = UIColor.clear
        }
        
        return [typeButton]
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
