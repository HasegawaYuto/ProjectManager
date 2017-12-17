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
    var minDate :NSDate!
    var maxDate:NSDate!
    var importance:Double!
    var status:Double = 0
    
    var taskLabelText :String!
    var taskDetailText:String!
    var importanceDouble:Double!
    var startDateValue:String!
    var endDateValue:String!
    var setPath :String!
    
    
    @IBAction func handleChargerButton(_ sender: Any) {
        self.saveTask()
        let chargerViewController = self.storyboard?.instantiateViewController(withIdentifier: "Charger") as! ChargerController
        chargerViewController.taskId = self.taskId
        navigationController?.pushViewController(chargerViewController, animated: true)
        print("DEBUG_PRINT:push Member")
    }
    
    @IBAction func handleAddButton(_ sender: Any) {
        self.saveTask()
    }
    
    func saveTask(){
        let taskLabelBool = self.taskLabelText != self.taskL.text
        let taskDetailBool = self.taskDetailText != self.detailT.text
        let importanceBool = self.importanceDouble != self.importanceV.rating
        let startDateBool = self.startDateValue != String(self.startDateP.date.timeIntervalSinceReferenceDate)
        let endDateBool = self.endDateValue != String(self.endDateP.date.timeIntervalSinceReferenceDate)
        let flag = taskLabelBool || taskDetailBool || importanceBool || startDateBool || endDateBool
        if flag && isManager  {
            print("DEBUG_PRINT:flag:\(flag)")
            if self.mode == 0 {
                self.setPath = Const.ProjectsPath + "/" + self.projectId + "/tasks"
                self.taskId = Database.database().reference().child(self.setPath!).childByAutoId().key as String
            }
            let projectRef = Database.database().reference().child(self.setPath!).child("tasks").child(self.taskId)
            let taskRef = Database.database().reference().child(Const.TasksPath).child(self.taskId)
            let saveData = ["label":self.taskL.text!,
                            "detail":self.detailT.text!,
                            "project":self.projectId!,
                            "status":self.status,
                            "startDate":String(self.startDateP.date.timeIntervalSinceReferenceDate),
                            "endDate":String(self.startDateP.date.timeIntervalSinceReferenceDate),
                            "importance":self.importanceV.rating] as [String : Any]
            //taskRef.setValue(saveData)
            self.taskLabelText = self.taskL.text!
            self.taskDetailText = self.detailT.text!
            self.importanceDouble = self.importanceV.rating
            self.startDateValue = String(self.startDateP.date.timeIntervalSinceReferenceDate)
            self.endDateValue = String(self.endDateP.date.timeIntervalSinceReferenceDate)
            
            projectRef.setValue(self.status)
            if mode == 0 {
                print("DEBUG_PRINT:mode create")
                taskRef.setValue(saveData)
                self.mode = 1
            } else {
                print("DEBUG_PRINT:mode update")
                taskRef.updateChildValues(saveData)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //super.viewWillDisappear(animated)
        //print("DEBUG_PRINT:call viewWillDisappear AddTask")
        super.viewWillDisappear(animated)
        if self.observe == true {
            //print("DEBUG_PRINT:observe:\(self.observe)")
            self.setPath = Const.TasksPath + "/" + self.taskId
            Database.database().reference().child(self.setPath).child("status").removeAllObservers()
            self.observe = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:call AddTask viewWillAppear")
        print("DEBUG_PRINT:projectId:\(self.projectId!)")
        super.viewWillAppear(animated)
        
        self.startDateP.minimumDate = self.minDate! as Date
        self.endDateP.minimumDate = self.minDate! as Date
        self.startDateP.maximumDate = self.maxDate! as Date
        self.endDateP.maximumDate = self.maxDate! as Date
        
        print("DEBUG_PRINT:set dates")
        
        if self.taskId != nil && self.observe == false{
            self.setPath = Const.TasksPath + "/" + self.taskId
            let taskRef = Database.database().reference().child(self.setPath)
            taskRef.child("status").observe(.value,with:{snapshot in
                self.status = snapshot.value as! Double
            })
            taskRef.observeSingleEvent(of:.value,with:{snapshot in
                let theTask = Tasks(taskdata:snapshot)
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
                self.taskLabelText = theTask.label!
                self.taskDetailText = theTask.detail!
                self.importanceDouble = theTask.importance!
                self.startDateValue = String(theTask.startDate!.timeIntervalSinceReferenceDate)
                self.endDateValue = String(theTask.endDate!.timeIntervalSinceReferenceDate)
            })
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
