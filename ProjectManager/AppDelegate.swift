//
//  AppDelegate.swift
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
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var tabBarController = UITabBarController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-2140888928025833~3908038199")
        
        ////   TabbarControllerの定義
        var viewControllers: [UIViewController] = []
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        let chartView = mainSB.instantiateViewController(withIdentifier: "PersonalTask")
        let personalView = mainSB.instantiateViewController(withIdentifier : "Personal")
        let navigationController1 = UINavigationController(rootViewController: chartView)
        let navigationController2 = UINavigationController(rootViewController: personalView)
        chartView.tabBarItem = UITabBarItem(title:"Tasks", image: UIImage(named: "list"),tag: 0 )
        personalView.tabBarItem = UITabBarItem(title: "Personal", image: UIImage(named: "man"), tag: 1 )
        
        viewControllers.append(navigationController1)
        viewControllers.append(navigationController2)

        AppDelegate.tabBarController.setViewControllers(viewControllers, animated: false)
        
        
        //logout()
 
        
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser!
            Database.database().reference().child(Const.UsersPath + "/" + user.uid).observeSingleEvent(of:.value,with:{snapshot in
                if snapshot.value == nil {
                    try! Auth.auth().signOut()
                } else {
                    let userTasksData = Database.database().reference().child(Const.TasksPath).queryOrdered(byChild:"chargers/" + user.uid).queryStarting(atValue:true)
                    userTasksData.observeSingleEvent(of:.value , with:{snapshot in
                        let datas = snapshot.children.allObjects as [Any]
                        if datas.count > 0 {
                            AppDelegate.tabBarController.selectedIndex = 0
                        }else{
                            AppDelegate.tabBarController.selectedIndex = 1
                        }
                    })
                }
            })
        }
        
        ////  ログインコントローラーのインスタンス
        let loginViewController = mainSB.instantiateViewController(withIdentifier: "Login")
        
        //// 表示の処理
        window = UIWindow()
        //window?.rootViewController = tabBarController
        
        /////このようにしてrootViewControllerを切り替えるのか？
         if Auth.auth().currentUser == nil {
            window?.rootViewController = loginViewController
         }else{
            window?.rootViewController = AppDelegate.tabBarController
         }
        
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //print("DEBUG_PRINT:handle url:\(url)")
        //if (url.host == "projectmanager-b8a6a.firebaseapp.com") {
        if (url.host == "oauth-swift") {
            OAuthSwift.handle(url: url)
        } else {
            OAuthSwift.handle(url: url)
        }
        return true
    }
    
    func logout(){
        if Auth.auth().currentUser != nil {
            try! Auth.auth().signOut()
        }
    }
    
}

/*
extension AppDelegate {
    func applicationHandle(url: URL) {
        print("DEBUG_PRINT:handle0 url:\(url)")
        if (url.host == "projectmanager-b8a6a.firebaseapp.com") {
            OAuthSwift.handle(url: url)
        } else {
            // Google provider is the only one wuth your.bundle.id url schema.
            OAuthSwift.handle(url: url)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("DEBUG_PRINT:handle1 url:\(url)")
        if (url.host == "projectmanager-b8a6a.firebaseapp.com") {
            OAuth2Swift.handle(url: url)
        }
        return true
    }
}
 */

