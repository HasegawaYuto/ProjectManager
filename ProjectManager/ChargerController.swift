//
//  ChargerController.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/14.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit

class ChargerController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var chargerT: UITableView!
    
    var taskId:String!

    @IBAction func handleSetButton(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        //print("Value: \(myItems[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Charger", for: indexPath as IndexPath)
        
        // Cellに値を設定する.
        cell.textLabel!.text = "hoge"
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT:call AddTask viewWillAppear")
        print("DEBUG_PRINT:projectId:\(self.taskId!)")
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.chargerT.delegate = self
        self.chargerT.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
