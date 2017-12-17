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
    
    var projectId : String!
    let user = Auth.auth().currentUser!
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
    
    @IBAction func handleMemberButton(_ sender: Any) {
        self.saveProject()
        
        let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "Member") as! MemberController
        memberViewController.projectId = self.projectId
        memberViewController.isManager = self.isManager
        navigationController?.pushViewController(memberViewController, animated: true)
        //print("DEBUG_PRINT:push Member")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.projectId != nil {
            if self.observe == false {
                let setPath = Const.ProjectsPath + "/" + self.projectId
                let projectDataRef = Database.database().reference().child(setPath)
                projectDataRef.observeSingleEvent(of: .value , with:{snapshot in
                    let theProject = Projects(projectdata:snapshot)
                        self.titleTF.text = theProject.title!
                        self.oldTitle = theProject.title!
                        self.detailTV.text = theProject.detail!
                        self.oldDetail = theProject.detail!
                        self.startDateP.date = theProject.startDate! as Date
                        let sDate = theProject.startDate?.timeIntervalSinceReferenceDate
                        self.oldStartDate = String(sDate!)
                        self.endDateP.date = theProject.endDate! as Date
                        let eDate = theProject.endDate?.timeIntervalSinceReferenceDate
                        self.oldStartDate = String(eDate!)
                        if theProject.members.count > 0{
                            self.mode = 1
                            if let theUserBool = theProject.members[self.user.uid] {
                                self.isManager = theUserBool
                                if self.isManager == false{
                                    self.SaveButton.isEnabled = false
                                    self.SaveButton.isHidden = true
                                }
                            }
                        }
                })
                
                self.observe = true
                
            }
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
                let setPath = Const.UsersPath + "/" + self.user.uid + "/projects"
                let userProjects = Database.database().reference().child(setPath)
                self.projectId = userProjects.childByAutoId().key as String
            }
            
            let sDate = self.startDateP.date.timeIntervalSinceReferenceDate
            let eDate = self.endDateP.date.timeIntervalSinceReferenceDate
            let postRef = Database.database().reference().child(Const.ProjectsPath)
            
            if self.mode == 0 {
                
                print("DEBUG_PRINT:create mode")
                let postData = ["title": self.titleTF.text!, "detail": self.detailTV.text!, "startDate":String(sDate),"endDate":String(eDate),"members":[user.uid :true]] as [String : Any]
                postRef.child(projectId).setValue(postData)
                let setPath = Const.UsersPath + "/" + self.user.uid + "/projects"
                let userProjectsRef = Database.database().reference().child(setPath)
                userProjectsRef.child(self.projectId).setValue(true)
                self.mode = 1
                
            }else{
                
                print("DEBUG_PRINT:update mode")
                let postData = ["title": self.titleTF.text!, "detail": self.detailTV.text!, "startDate":String(sDate),"endDate":String(eDate)] as [String : Any]
                postRef.child(self.projectId).updateChildValues(postData)
                
            }
            
            self.oldTitle = self.titleTF.text!
            self.oldDetail = self.detailTV.text!
            self.oldStartDate = String(self.startDateP.date.timeIntervalSinceReferenceDate)
            self.oldEndDate = String(self.endDateP.date.timeIntervalSinceReferenceDate)
        }
    }
}
