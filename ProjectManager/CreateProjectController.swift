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
        if self.projectId == nil {
            self.createProject()
        }else{
            self.saveProject(projectId:self.projectId)
        }
    }
    @IBAction func handleMemberButton(_ sender: Any) {
        let IsTitleChanged = self.oldTitle != self.titleTF.text!
        let IsDetailChanged = self.oldDetail != self.detailTV.text!
        let IsStartDateChanged = self.oldStartDate != String(self.startDateP.date.timeIntervalSinceReferenceDate)
        let IsEndDateChanged = self.oldEndDate != String(self.endDateP.date.timeIntervalSinceReferenceDate)
        if self.projectId == nil {
            self.createProject()
        } else if (self.isManager && ( IsTitleChanged || IsDetailChanged || IsStartDateChanged || IsEndDateChanged )){
            self.saveProject(projectId:self.projectId)
        }
        let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "Member") as! MemberController
        memberViewController.projectId = self.projectId
        memberViewController.isManager = self.isManager
        navigationController?.pushViewController(memberViewController, animated: true)
        print("DEBUG_PRINT:push Member")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.projectId != nil {
            self.mode = 1
            print("DEBUG_PRINT:projectId != nil")
            if self.observe == false {
                print("DEBUG_PRINT:observe false")
                let setPath = Const.ProjectsPath + "/" + self.projectId
                let projectDataRef = Database.database().reference().child(setPath)
                //print("DEBUG_PRINT:set ref")
                projectDataRef.child("title").observeSingleEvent(of: .value , with:{snapshot in
                    self.titleTF.text = snapshot.value as? String
                    self.oldTitle = snapshot.value as? String
                    //print("DEBUG_PRINT:set value title")
                })
                projectDataRef.child("detail").observeSingleEvent(of: .value , with:{snapshot in
                    self.detailTV.text = snapshot.value as? String
                    self.oldDetail = snapshot.value as? String
                    //print("DEBUG_PRINT:set value detail")
                })
                projectDataRef.child("startDate").observeSingleEvent(of: .value , with:{snapshot in
                    let startDateDouble = Float(snapshot.value as! String)
                    self.startDateP.date = NSDate(timeIntervalSinceReferenceDate : TimeInterval(startDateDouble!)) as Date
                    self.oldStartDate = snapshot.value as! String
                })
                projectDataRef.child("endDate").observeSingleEvent(of: .value , with:{snapshot in
                    let endDateDouble = Float(snapshot.value as! String)
                    self.endDateP.date = NSDate(timeIntervalSinceReferenceDate : TimeInterval(endDateDouble!)) as Date
                    self.oldEndDate = snapshot.value as! String
                })
                projectDataRef.child("members").child(self.user.uid).observeSingleEvent(of: .value , with:{snapshot in
                    self.isManager = snapshot.value as! Bool
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createProject(){
        print("DEBUG_PRINT:call createProject")
        let setPath = Const.UsersPath + "/" + self.user.uid + "/projects"
        let userProjects = Database.database().reference().child(setPath)
        self.projectId = userProjects.childByAutoId().key as String
        //userProjects.child(self.projectId!).setValue(true)
        //print("DEBUG_PRINT:user->projectsに保存")
        
        self.saveProject(projectId:self.projectId)
        //print("DEBUG_PRINT:projectsを新規作成")
        userProjects.child(self.projectId!).setValue(true)
    }
    
    func saveProject(projectId:String){
        print("DEBUG_PRINT:call saveProject")
        let IsTitleChanged = self.oldTitle != self.titleTF.text!
        let IsDetailChanged = self.oldDetail != self.detailTV.text!
        let IsStartDateChanged = self.oldStartDate != String(self.startDateP.date.timeIntervalSinceReferenceDate)
        let IsEndDateChanged = self.oldEndDate != String(self.endDateP.date.timeIntervalSinceReferenceDate)
        if (self.isManager && ( IsTitleChanged || IsDetailChanged || IsStartDateChanged || IsEndDateChanged )) || self.mode == 0 {
            print("DEBUG_PRINT:do save")
            let sDate = self.startDateP.date.timeIntervalSinceReferenceDate
            let eDate = self.endDateP.date.timeIntervalSinceReferenceDate
            let postRef = Database.database().reference().child(Const.ProjectsPath)
        //print("DEBUG_PRINT:\(sDate)")
            if self.mode == 0 {
                print("DEBUG_PRINT:create mode")
                let postData = ["title": self.titleTF.text!, "detail": self.detailTV.text!, "startDate":String(sDate),"endDate":String(eDate),"members":[user.uid as String :true]] as [String : Any]
                postRef.child(projectId).setValue(postData)
            }else{
                print("DEBUG_PRINT:update mode")
                let postData = ["title": self.titleTF.text!, "detail": self.detailTV.text!, "startDate":String(sDate),"endDate":String(eDate)] as [String : Any]
                postRef.child(projectId).updateChildValues(postData)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
