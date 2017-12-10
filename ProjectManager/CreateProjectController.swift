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
    
    @IBAction func handleSaveButton(_ sender: Any) {
        if self.projectId == nil {
            self.createProject()
        }else{
            self.saveProject(projectId:self.projectId)
        }
    }
    @IBAction func handleMemberButton(_ sender: Any) {
        if self.projectId == nil {
            self.createProject()
        }
        let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "Member") as! MemberController
        memberViewController.projectId = self.projectId
        navigationController?.pushViewController(memberViewController, animated: true)
        print("DEBUG_PRINT:push Member")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.detailTV.text = self.user.uid
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
        userProjects.child(projectId!).setValue(true)
        print("DEBUG_PRINT:user->projectsに保存")
        
        self.saveProject(projectId:self.projectId)
        print("DEBUG_PRINT:projectsを新規作成")
    }
    
    func saveProject(projectId:String){
        print("DEBUG_PRINT:call saveProject")
        let sDate = NSDate.timeIntervalSinceReferenceDate
        let eDate = NSDate.timeIntervalSinceReferenceDate
        let postRef = Database.database().reference().child(Const.ProjectsPath)
        let postData = ["title": titleTF.text!, "detail": detailTV.text!, "startDate":String(sDate),"endDate":String(eDate),"members":[user.uid as String :true]] as [String : Any]
        postRef.child(projectId).setValue(postData)
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
