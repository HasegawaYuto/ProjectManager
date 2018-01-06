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
import OAuthSwift
import SafariServices

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    
    var tabBarCotroller : UITabBarController!
    
    var oauthswift: OAuthSwift?
    
    let consumerData:[String:String] =
        ["consumerKey":"1061223c7f91f3d40f23",
         "consumerSecret":"348797adb970d6106a2387608cf0cd1859a15b0b"]


    @IBAction func handleCreateNewAccount(_ sender: Any) {
        if let email = emailTF.text, let password = passwordTF.text, let name = nameTF.text {
            
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
                        let postRef = Database.database().reference().child(Const.UsersPath).child(user.uid)
                        let postData = ["name": user.displayName,"mail":user.email]
                        postRef.setValue(postData)
                        
                        // 画面を閉じてViewControllerに戻る
                        //self.dismiss(animated: true, completion: nil)
                        self.loadTabBarController()
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
                print("DEBUG_PRINT:empty")
                return
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT:error: " + error.localizedDescription)
                    return
                } else {
                    print("DEBUG_PRINT: ログインに成功しました。")
                    
                    // 画面を閉じてViewControllerに戻る
                    //self.dismiss(animated: true, completion: nil)
                    self.loadTabBarController()
                }
            }
        }
    }
    
    func loadTabBarController(){
        //print("DEBUG_PRINT:call loadTabBarController")
        //self.tabBarCotroller = AppDelegate.tabBarController
        //print("DEBUG_PRINT:set tabBarCotroller")
        if Auth.auth().currentUser != nil {
            //print("DEBUG_PRINT:login yes")
            let user = Auth.auth().currentUser!
            let userTasksData = Database.database().reference().child(Const.TasksPath).queryOrdered(byChild:"chargers/" + user.uid).queryStarting(atValue:true)
            userTasksData.observeSingleEvent(of: .value , with:{snapshot in
                //print("DEBUG_PRINT:ch task exists")
                let datas = snapshot.children.allObjects as [Any]
                if datas.count > 0 {
                    AppDelegate.tabBarController.selectedIndex = 0
                    //print("DEBUG_PRINT:task exists")
                }else{
                    AppDelegate.tabBarController.selectedIndex = 1
                    //print("DEBUG_PRINT:task  not exists")
                }
                self.view.window?.rootViewController = AppDelegate.tabBarController
                self.dismiss(animated: true, completion: nil)
            } )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("DEBUG_PRINT:viewWillAppear")
    }
    
    
    @IBAction func handleLogInWithGitHub(_ sender: Any) {
        self.doOAuthGithub(self.consumerData)
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
        //print("DEBUG_PRINT:pushエンター")
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        //print("DEBUG_PRINT:キーボードしまう")
        return true
    }
    
    func doOAuthGithub(_ serviceParameters: [String:String]){
        let oauthswift = OAuth2Swift(
            consumerKey:    serviceParameters["consumerKey"]!,
            consumerSecret: serviceParameters["consumerSecret"]!,
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = self.getURLHandler()
        //print("DEBUG_PRINT:1")
        let state = generateState(withLength: 20)
        //print("DEBUG_PRINT:2")
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "oauth-swift://oauth-callback/github")!,
            scope: "user,repo",
            state: state,
            success: { credential, response, parameters in
                print("DEBUG_PRINT:credential:\(credential)")
                let accessToken = credential.oauthToken
                let credentialGitHub = GitHubAuthProvider.credential(withToken: accessToken)
                Auth.auth().signIn(with: credentialGitHub) { (user, error) in
                    if let error = error {
                        print("DEBUG_PRINT:sign in error:\(error.localizedDescription)")
                        return
                    } else {
                        
                        let user = Auth.auth().currentUser!
                        let Ref = Database.database().reference().child(Const.UsersPath).child(user.uid)
                        Ref.observeSingleEvent(of: .value, with:{snapshot in
                            let datas = snapshot.children.allObjects as [Any]
                            if datas.count == 0 {
                                let postRef = Database.database().reference().child(Const.UsersPath).child(user.uid)
                                let postData = ["name": "Loing with GitHub User","mail":user.email]
                                postRef.setValue(postData)
                            }
                        })
                        
                        self.loadTabBarController()
                    }
                }
            },
            failure: { error in
                print(error.description)
            }
        )
        //print("DEBUG_PRINT:7")
    }
    
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        //print("DEBUG_PRINT:getURLHandler")
        if #available(iOS 9.0, *) {
            let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
            //print("DEBUG_PRINT:set handler")
            handler.presentCompletion = {
                //print("Safari presented")
            }
            handler.dismissCompletion = {
                //print("Safari dismissed")
            }
            handler.factory = { url in
                let controller = SFSafariViewController(url: url)
                // Customize it, for instance
                if #available(iOS 10.0, *) {
                    //  controller.preferredBarTintColor = UIColor.red
                }
                return controller
            }
            return handler
        }
        return OAuthSwiftOpenURLExternally.sharedInstance
    }

}

/*
extension LoginController: OAuthWebViewControllerDelegate {
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        oauthswift?.cancel()
    }
}
*/
