//
//  MemberController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/05.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit

class MemberController: UIViewController {
    var projectId: String!
    
    @IBAction func handleInviteButton(_ sender: Any) {
        let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "Invite")
        navigationController?.pushViewController(memberViewController!, animated: true)
        print("DEBUG_PRINT:push Invite")

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("DEBUG_PRINT:\(self.projectId)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
