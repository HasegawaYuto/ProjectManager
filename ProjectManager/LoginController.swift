//
//  LoginController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/04.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!


    @IBAction func handleCreateNewAccount(_ sender: Any) {
        if let email = emailTF.text, let password = passwordTF.text, let name=nameTF.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if email.characters.isEmpty || password.characters.isEmpty || name.characters.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                return
            }
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // 表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("DEBUG_PRINT: " + error.localizedDescription)
                        }
                        print("DEBUG_PRINT: [displayName = \(String(describing: user.displayName))]の設定に成功しました。")
                        
                        //usersデータベースに保存
                        let postRef = Database.database().reference().child(Const.UsersPath)
                        let postData = ["name": user.displayName]
                        postRef.child(user.uid).setValue(postData)
                        print("DEBUG_PRINT:usersに情報を保存")
                        
                        // 画面を閉じてViewControllerに戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("DEBUG_PRINT: displayNameの設定に失敗しました。")
                }
            }
        }
    }
    
    @IBAction func handleLogIn(_ sender: Any) {
        if let email = emailTF.text, let password = passwordTF.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if email.characters.isEmpty || password.characters.isEmpty {
                return
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                } else {
                    print("DEBUG_PRINT: ログインに成功しました。")
                    
                    // 画面を閉じてViewControllerに戻る
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func handleLogInWithGitHub(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        self.nameTF.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("DEBUG_PRINT:pushエンター")
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        print("DEBUG_PRINT:キーボードしまう")
        return true
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
