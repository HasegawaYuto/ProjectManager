//
//  InviteMemberController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/05.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class InviteMemberController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var findL: UILabel!
    @IBOutlet weak var userL: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var projectId :String!
    var searchUserId :String!
    var searchBool :Bool = false
    
    @IBAction func handleInviteButton(_ sender: Any) {
        print("DEBUG_PRINT:call handleInviteButton")
        let userPath = Const.UsersPath + "/" + self.searchUserId
        print("DEBUG_PRINT:path:\(userPath)")
        let userPathRef = Database.database().reference().child(userPath).child("invited").child(self.projectId)
        userPathRef.setValue(true)
        self.userL.text = "Complete invitation"
        self.findL.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT:projectId:\(self.projectId!)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.searchBool {
            Database.database().reference().child(Const.UsersPath).removeAllObservers()
            print("DEBUG_PRINT:remove observe")
        }
        let userRef = Database.database().reference().child(Const.UsersPath).queryOrdered(byChild: "mail").queryEqual(toValue: self.searchBar.text)
        userRef.observeSingleEvent(of:.value,with:{snapshot in
            print("DEBUG_PRINT:search start")
            let datas = snapshot.children.allObjects as [Any]
            if datas.count > 0 {
                let theUser = Users(userdata:datas[0] as! DataSnapshot)
                print("DEBUG_PRINT:set theUser")
                self.userL.text = theUser.name
                //print("DEBUG_PRINT:set name:\(theUser.name)")
                self.searchUserId = theUser.id
                self.userL.isHidden = false
                self.findL.isHidden = false
                self.searchBool = true
                self.inviteButton.isHidden = false
                self.inviteButton.isEnabled = true
            } else {
                self.userL.text = "No such user"
                self.userL.isHidden = false
                self.findL.isHidden = true
                self.searchBool = false
                self.inviteButton.isHidden = true
                self.inviteButton.isEnabled = false
            }
        })
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
