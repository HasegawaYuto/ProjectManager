//
//  ChargerController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/14.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChargerController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var chargerT: UITableView!
    
    var taskId:String!
    var projectId:String!
    var isManager:Bool = false
    var observe:Bool = false
    
    var chargers:[Users]=[]

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT:didSelectRowAt")
        
        let usersPath = Const.UsersPath + "/" + self.chargers[indexPath.row].id! + "/tasks/" + self.taskId!
        let userRef = Database.database().reference().child(usersPath)
        
        let tasksPath = Const.TasksPath + "/" + self.taskId! + "/chargers/" + self.chargers[indexPath.row].id!
        let taskRef = Database.database().reference().child(tasksPath)
        
        if self.chargers[indexPath.row].tasks[self.taskId] != nil {
            print("DEBUG_PRINT:!= nil")
            userRef.removeValue()
            taskRef.removeValue()
        }else{
            print("DEBUG_PRINT:== nil")
            userRef.setValue(true)
            taskRef.setValue(true)
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let usersFilter = Const.users.filter({ $0.projects[self.projectId]! >= 1 })
        self.chargers = usersFilter.sorted(by:{$0.projects[self.projectId]! > $1.projects[self.projectId]!})
        return self.chargers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Charger", for: indexPath as IndexPath)
        
        // Cellに値を設定する.
        cell.textLabel!.text = self.chargers[indexPath.row].name
        if self.isManager == false {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        if let bool = self.chargers[indexPath.row].tasks[self.taskId] {
            if bool == true {
                print("DEBUG_PRINT:bool:true")
                cell.accessoryType = .checkmark
            }
        }else{
            print("DEBUG_PRINT:bool:nil")
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //super.viewWillDisappear(animated)
        super.viewWillDisappear(animated)
        if self.observe == true {
            print("DEBUG_PRINT:[charger]call observer off")
            Database.database().reference().child(Const.UsersPath).removeAllObservers()
            self.observe = false
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:call charger viewWillAppear")
        super.viewWillAppear(animated)
        
        if self.observe == false {
            let userRef = Database.database().reference().child(Const.UsersPath).queryOrdered(byChild:"projects/" + self.projectId).queryStarting(atValue: 1)
            
            userRef.observe(.childAdded,with:{snapshot in
                print("DEBUG_PRINT:[chargers] user add")
                let theUser = Users(snapshot)
                Const.addUserData(theUser)
                self.chargerT.reloadData()
            })
            
            
            userRef.observe(.childChanged,with:{snapshot in
                print("DEBUG_PRINT:[chargers] user change")
                let theUser = Users(snapshot)
                Const.reloadUserData(theUser)
                self.chargerT.reloadData()
            })
            
            userRef.observe(.childRemoved,with:{snapshot in
                print("DEBUG_PRINT:[chargers] user remove")
                let theUser = Users(snapshot)
                Const.removeUserData(theUser)
                self.chargerT.reloadData()
            })
            
            self.observe = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.chargerT.delegate = self
        self.chargerT.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
