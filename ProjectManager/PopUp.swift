//
//  PopUp.swift
//  ProjectManager
//
//  Created by 長谷川勇斗 on 2017/12/24.
//  Copyright © 2017年 長谷川勇斗. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PopUp: UIViewController {
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var initButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var debugButton: UIButton!

    @IBOutlet weak var readyHeight: NSLayoutConstraint!
    @IBOutlet weak var initHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewHeight: NSLayoutConstraint!
    @IBOutlet weak var finishHeight: NSLayoutConstraint!
    @IBOutlet weak var debugHeight: NSLayoutConstraint!
    
    var task : Tasks!
    var isManager:Bool = false
    var status2: Int!
    var status:Double!
    var realStartDate:NSDate!
    var layers:[CAShapeLayer]=[]
    
    @IBAction func handleReadyButton(_ sender: Any) {
        print("DEBUG_PRINT:self.initButton")
        self.readyButton.isHidden = true
        self.readyHeight.constant = 0
        self.initButton.isHidden = false
        self.initHeight.constant = 40
        
        let path = Const.TasksPath + "/" + self.task.id! + "/status2"
        Database.database().reference().child(path).setValue(1)
    }
    
    @IBAction func handleInitButton(_ sender: Any) {
        print("DEBUG_PRINT:slider")
        self.initButton.isHidden = true
        self.initHeight.constant = 0
        self.slider.isHidden = false
        self.slider.value = Float(self.status!)
        
        let path = Const.TasksPath + "/" + self.task.id! + "/status2"
        Database.database().reference().child(path).setValue(3)
        
        let now = NSDate.timeIntervalSinceReferenceDate
        let path2 = Const.TasksPath + "/" + self.task.id! + "/realStartDate"
        Database.database().reference().child(path2).setValue(String(now))
    }
    
    @IBAction func handleReviewButton(_ sender: Any) {
        print("DEBUG_PRINT:finish,debug")
        self.reviewButton.isHidden = true
        self.reviewHeight.constant = 0
        self.finishButton.isHidden = false
        self.finishHeight.constant = 40
        self.debugButton.isHidden = false
        self.debugHeight.constant = 40
        
        let path = Const.TasksPath + "/" + self.task.id! + "/status2"
        Database.database().reference().child(path).setValue(4)
    }
    
    @IBAction func handleFinishButton(_ sender: Any) {
        let path = Const.TasksPath + "/" + self.task.id! + "/status2"
        Database.database().reference().child(path).setValue(6)
        
        let now = NSDate.timeIntervalSinceReferenceDate
        let path2 = Const.TasksPath + "/" + self.task.id! + "/realEndDate"
        Database.database().reference().child(path2).setValue(String(now))
    }
    
    @IBAction func handleDebugButton(_ sender: Any) {
        self.finishButton.isHidden = true
        self.finishHeight.constant = 0
        self.debugButton.isHidden = true
        self.debugHeight.constant = 0
        self.reviewButton.isHidden = false
        self.reviewHeight.constant = 40
        
        let path = Const.TasksPath + "/" + self.task.id! + "/status2"
        Database.database().reference().child(path).setValue(5)
    }
    
    @IBAction func handleStopButton(_ sender: Any) {
        if self.isManager {
            self.allUIOff()
            let path = Const.TasksPath + "/" + self.task.id! + "/status2"
            if self.status2 != 2 {
                print("DEBUG_PRINT:not status2 != 2")
                self.slider.isHidden = true
                self.status2 = 2
                Database.database().reference().child(path).setValue(2)
            } else {
                print("DEBUG_PRINT:not status2 == 2")
                self.slider.value = Float(self.status!)
                if self.status! == 0.0 && self.realStartDate == nil {
                    print("DEBUG_PRINT:not status == 0.0 not realStateDate")
                    self.initButton.isHidden = false
                    self.initHeight.constant = 40
                    self.status2 = 1
                    Database.database().reference().child(path).setValue(1)
                } else if self.status! == 1.0 {
                    print("DEBUG_PRINT:status == 1.0")
                    self.slider.isHidden = false
                    self.reviewButton.isHidden = false
                    self.reviewHeight.constant = 40
                    self.status2 = 3
                    Database.database().reference().child(path).setValue(3)
                } else {
                    print("DEBUG_PRINT:status :\(self.status!)")
                    self.slider.isHidden = false
                    self.status2 = 3
                    Database.database().reference().child(path).setValue(3)
                }
            }
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.status2 = self.task.status2!
        self.status = self.task.status!
        if self.task.realStartDate != nil {
            self.realStartDate = self.task.realStartDate!
        }
        
        self.taskTitle.text = self.task.label!
        if self.task.status2! == 0 {
            self.readyButton.isHidden = false
            self.readyHeight.constant = 40
        }else if self.task.status2! == 1 {
            self.initButton.isHidden = false
            self.initHeight.constant = 40
        } else if (self.task.status2! == 3 && self.task.status! == 1.0 ) || self.task.status2! == 5 {
            self.reviewButton.isHidden = false
            self.reviewHeight.constant = 40
        } else if self.task.status2! == 4 {
            self.finishButton.isHidden = false
            self.finishHeight.constant = 40
            self.debugButton.isHidden = false
            self.debugHeight.constant = 40
        }
        
        if self.task.status2! > 2 {
            self.slider.isHidden = false
            self.slider.value = Float(self.task.status!)
        }
        
        //self.drawCircle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.drawCircle()
    }
    
    func onChangeValueSlider(_ sender : UISlider){
        //print("DEBUG_PRINT:call change")
        let path = Const.TasksPath + "/" + self.task.id! + "/status"
        Database.database().reference().child(path).setValue(Double(sender.value))
        self.status = Double(sender.value)
        
        let path2 = Const.ProjectsPath + "/" + self.task.project! + "/tasks/" + self.task.id!
        Database.database().reference().child(path2).setValue(Double(sender.value))
        
        self.drawCircle()
        
        if sender.value == 1.0 {
            self.reviewButton.isHidden = false
            self.reviewHeight.constant = 40
        } else {
            self.allUIOff()
            self.reviewButton.isHidden = true
            self.reviewHeight.constant = 0
            self.status2 = 3
            let path2 = Const.TasksPath + "/" + self.task.id! + "/status2"
            Database.database().reference().child(path2).setValue(3)
        }
    }
    
    func allUIOff(){
        self.reviewButton.isHidden = true
        self.reviewHeight.constant = 0
        self.finishButton.isHidden = true
        self.finishHeight.constant = 0
        self.debugButton.isHidden = true
        self.debugHeight.constant = 0
    }
    
    func drawCircle(){
        if self.layers.count > 0 {
            self.layers.forEach {
                $0.removeFromSuperlayer()
            }
        }
        let pi = CGFloat(Double.pi)
        let start:CGFloat = -1 *  pi * 0.5
        let end :CGFloat = ( -1 * pi * 0.5 ) + 2 * pi * CGFloat(self.status)
        
        //let w0 = self.circleView.frame.origin.x
        let w = self.circleView.frame.width
        let h = self.circleView.frame.height
        
        let path: UIBezierPath = UIBezierPath();
        path.move(to: CGPoint(x: w/2 , y: h/2))
        path.addArc(withCenter: CGPoint(x: w/2 , y: h/2), radius: w/2 , startAngle: start, endAngle: end, clockwise: true)
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.orange.cgColor
        layer.path = path.cgPath
        
        self.circleView.layer.insertSublayer(layer,at:0)
        self.percentLabel.text = String(Int(100 * self.status)) + "%"
        self.layers.append(layer)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.slider.addTarget(self, action: #selector(self.onChangeValueSlider), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
