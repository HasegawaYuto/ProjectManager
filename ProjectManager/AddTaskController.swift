//
//  AddTaskController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/13.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Cosmos

class AddTaskController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var taskL: UITextField!
    @IBOutlet weak var detailT: UITextView!
    @IBOutlet weak var startDateP: UIDatePicker!
    @IBOutlet weak var endDateP: UIDatePicker!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var chagerButton: UIBarButtonItem!
    @IBOutlet weak var importanceV: CosmosView!
    
    var projectId :String!
    var mode:Int = 0
    var observe :Bool = false
    var taskId : String!
    var isManager:Bool = false
    var minDate :Date!
    var maxDate:Date!
    var importance:Double!
    var status:Double = 0

    var setPath :String!
    
    
    @IBAction func handleChargerButton(_ sender: Any) {
        self.saveTask()
        let chargerViewController = self.storyboard?.instantiateViewController(withIdentifier: "Charger") as! ChargerController
        chargerViewController.taskId = self.taskId
        chargerViewController.projectId = self.projectId
        chargerViewController.isManager = self.isManager
        navigationController?.pushViewController(chargerViewController, animated: true)
        print("DEBUG_PRINT:push Member")
    }
    
    @IBAction func handleAddButton(_ sender: Any) {
        self.saveTask()
    }
    
    func saveTask(){
        var flag = false
        if Const.tasks.filter({$0.id == self.taskId }).count > 0 {
            let theTask = Const.tasks.filter({$0.id == self.taskId })[0]
            let taskLabelBool = theTask.label != self.taskL.text
            let taskDetailBool = theTask.detail != self.detailT.text
            let importanceBool = theTask.importance != self.importanceV.rating
            let startDateBool = String(theTask.startDate!.timeIntervalSince1970) != String(self.startDateP.date.timeIntervalSince1970)
            let endDateBool = String(theTask.endDate!.timeIntervalSince1970) != String(self.endDateP.date.timeIntervalSince1970)
            
            flag = taskLabelBool || taskDetailBool || importanceBool || startDateBool || endDateBool
        }else{
            flag = true
        }
        
        if flag && self.isManager  {
            //print("DEBUG_PRINT:flag:\(flag)")
            //print("DEBUG_PRINT:isManager:\(self.isManager)")
            if self.mode == 0 {
                self.setPath = Const.ProjectsPath + "/" + self.projectId
                self.taskId = Database.database().reference().child(self.setPath!).childByAutoId().key as String
                
                let taskRef = Database.database().reference().child(Const.TasksPath + "/" + self.taskId!)
                taskRef.observe(.value,with:{snapshot in
                    let theTask = Tasks(snapshot)
                    Const.addTaskData(theTask)
                })
                self.observe = true
            }
            let projectRef = Database.database().reference().child(self.setPath!).child("tasks").child(self.taskId)
            let taskRef = Database.database().reference().child(Const.TasksPath).child(self.taskId)
            
            
            //print("DEBUG_PRINT:save Sdate:\(self.startDateP.date)(\(self.startDateP.date.timeIntervalSinceReferenceDate))")
            //print("DEBUG_PRINT:save Edate:\(self.endDateP.date)(\(self.endDateP.date.timeIntervalSinceReferenceDate))")
            if mode == 0 {
                print("DEBUG_PRINT:mode create")
                let saveData = ["label":self.taskL.text!,
                                "detail":self.detailT.text!,
                                "project":self.projectId!,
                                "status":0.0,
                                "status2":0,
                                "startDate":String(self.startDateP.date.timeIntervalSince1970),
                                "endDate":String(self.endDateP.date.timeIntervalSince1970),
                                "importance":self.importanceV.rating] as [String : Any]
                projectRef.setValue(0.0)
                taskRef.setValue(saveData)
                self.mode = 1
            } else {
                print("DEBUG_PRINT:mode update")
                let saveData = ["label":self.taskL.text!,
                                "detail":self.detailT.text!,
                                "startDate":String(self.startDateP.date.timeIntervalSince1970),
                                "endDate":String(self.endDateP.date.timeIntervalSince1970),
                                "importance":self.importanceV.rating] as [String : Any]
                taskRef.updateChildValues(saveData)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //super.viewWillDisappear(animated)
        //print("DEBUG_PRINT:call viewWillDisappear AddTask")
        super.viewWillDisappear(animated)
        if self.observe == true {
            print("DEBUG_PRINT:[Add Task]call observer off")
            self.setPath = Const.TasksPath + "/" + self.taskId
            Database.database().reference().child(self.setPath).removeAllObservers()
            self.observe = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:call AddTask viewWillAppear")
        super.viewWillAppear(animated)
        
        self.startDateP.minimumDate = self.minDate! as Date
        self.endDateP.minimumDate = self.minDate! as Date
        self.startDateP.maximumDate = self.maxDate! as Date
        self.endDateP.maximumDate = self.maxDate! as Date
        
        if self.taskId != nil && self.observe == false{
            
            let taskRef = Database.database().reference().child(Const.TasksPath + "/" + self.taskId!)
            taskRef.observe(.value,with:{snapshot in
                let theTask = Tasks(snapshot)
                Const.addTaskData(theTask)
            })
            
            self.setPath = Const.TasksPath + "/" + self.taskId
            
            let theTask = Const.tasks.filter({$0.id == self.taskId })[0]
            self.taskL.text = theTask.label!
            self.detailT.text = theTask.detail!
            self.importanceV.rating = theTask.importance!
            self.startDateP.date = theTask.startDate! as Date
            self.endDateP.date = theTask.endDate! as Date
            self.importance = theTask.importance!
            
            if self.isManager == false {
                self.addButton.isEnabled = false
                self.addButton.isHidden = true
                self.chagerButton.isEnabled = false
            }
            self.mode = 1
            self.observe = true
        } else {
            self.importanceV.rating = 1
        }
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("DEBUG_PRINT:textFieldShouldReturn \(self.taskL.text!)")
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskL.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
