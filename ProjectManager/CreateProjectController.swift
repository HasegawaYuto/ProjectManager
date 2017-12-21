//
//  CreateProjectController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/05.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class CreateProjectController: UIViewController {
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var detailTV: UITextView!
    @IBOutlet weak var startDateP: UIDatePicker!
    @IBOutlet weak var endDateP: UIDatePicker!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var memberButton: UIBarButtonItem!
    
    var projectId : String!
    var observe :Bool = false
    var isManager : Bool = false
    var mode:Int = 0
    
    var oldTitle:String!
    var oldDetail:String!
    var oldStartDate:String!
    var oldEndDate:String!
    
    @IBAction func handleSaveButton(_ sender: Any) {
        self.saveProject()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.SaveButton.isEnabled = false
        self.memberButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.SaveButton.isEnabled = true
        self.memberButton.isEnabled = true
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    @IBAction func handleMemberButton(_ sender: Any) {
        self.saveProject()
        
        let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "Member") as! MemberController
        memberViewController.projectId = self.projectId
        memberViewController.isManager = self.isManager
        navigationController?.pushViewController(memberViewController, animated: true)
        //print("DEBUG_PRINT:push Member")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:[create p] call viewWillAppear")
        super.viewWillAppear(animated)
        if self.observe == false {
            if self.projectId != nil {
                print("DEBUG_PRINT:[create p] self.projectId != nil")
                
                let projectRef = Database.database().reference().child(Const.ProjectsPath).child(self.projectId!)
                
                
                projectRef.observe(.value,with:{snapshot in
                    print("DEBUG_PRINT:[create p] call value:\(snapshot)")
                    let theProject = Projects(snapshot)
                    Const.addProjectData(theProject)
                })
                
                let oldproject = Const.projects.filter({ $0.id == self.projectId! })[0]
                self.titleTF.text = oldproject.title!
                self.oldTitle = oldproject.title!
                
                self.detailTV.text = oldproject.detail!
                self.oldDetail = oldproject.detail!
                
                self.startDateP.date = oldproject.startDate! as Date
                let sDate = oldproject.startDate?.timeIntervalSinceReferenceDate
                self.oldStartDate = String(sDate!)
                
                self.endDateP.date = oldproject.endDate! as Date
                let eDate = oldproject.endDate?.timeIntervalSinceReferenceDate
                self.oldStartDate = String(eDate!)
                
                if oldproject.members.count > 0{
                    self.mode = 1
                    if let theUserBool = oldproject.members[Const.user.id!] {
                        self.isManager = theUserBool == 2
                        if self.isManager == false{
                            self.SaveButton.isEnabled = false
                            self.SaveButton.isHidden = true
                        }
                    }
                }
            }else{
                print("DEBUG_PRINT:[create p] self.projectId == nil")
            }
            self.observe = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //super.viewWillDisappear(animated)
        print("DEBUG_PRINT:call viewWillDisappear Create")
        super.viewWillDisappear(animated)
        self.observe = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveProject(){
        print("DEBUG_PRINT:call saveProject")
        let IsTitleChanged = self.oldTitle != self.titleTF.text!
        let IsDetailChanged = self.oldDetail != self.detailTV.text!
        let IsStartDateChanged = self.oldStartDate != String(self.startDateP.date.timeIntervalSinceReferenceDate)
        let IsEndDateChanged = self.oldEndDate != String(self.endDateP.date.timeIntervalSinceReferenceDate)
        let isChanged = IsTitleChanged || IsDetailChanged || IsStartDateChanged || IsEndDateChanged
        
        if isChanged && self.isManager{
            print("DEBUG_PRINT:do save")
            
            if self.projectId == nil {
                let setPath = Const.UsersPath + "/" + Const.user.id! + "/projects"
                let userProjects = Database.database().reference().child(setPath)
                self.projectId = userProjects.childByAutoId().key as String
                
                
                let projectRef = Database.database().reference().child(Const.ProjectsPath).child(self.projectId!)
                
                projectRef.observe(.value,with:{snapshot in
                    print("DEBUG_PRINT:[create p] call value:\(snapshot)")
                    let theProject = Projects(snapshot)
                    Const.addProjectData(theProject)
                })
                self.observe = true
            }
            
            let sDate = self.startDateP.date.timeIntervalSinceReferenceDate
            let eDate = self.endDateP.date.timeIntervalSinceReferenceDate
            let postRef = Database.database().reference().child(Const.ProjectsPath)
            
            if self.mode == 0 {
                
                print("DEBUG_PRINT:create mode")
                
                let postData = ["title": self.titleTF.text!, "detail": self.detailTV.text!, "startDate":String(sDate),"endDate":String(eDate),"members":[Const.user.id! :2]] as [String : Any]
                postRef.child(self.projectId!).setValue(postData)
                
                let setPath = Const.UsersPath + "/" + Const.user.id! + "/projects"
                let userProjectsRef = Database.database().reference().child(setPath)
                userProjectsRef.child(self.projectId!).setValue(2)
                
                self.mode = 1
                
                print("DEBUG_PRINT:save done")
                
            }else{
                
                print("DEBUG_PRINT:update mode")
                let postData = ["title": self.titleTF.text!, "detail": self.detailTV.text!, "startDate":String(sDate),"endDate":String(eDate)] as [String : Any]
                postRef.child(self.projectId).updateChildValues(postData)
                print("DEBUG_PRINT:save done")
            }
            
            self.oldTitle = self.titleTF.text!
            self.oldDetail = self.detailTV.text!
            self.oldStartDate = String(self.startDateP.date.timeIntervalSinceReferenceDate)
            self.oldEndDate = String(self.endDateP.date.timeIntervalSinceReferenceDate)
        }
    }
}
