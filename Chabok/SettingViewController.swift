//
//  SettingViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/27/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit
import AdpPushClient

class SettingViewController: UIViewController {
    
    let manager = PushClientManager.default()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func changeNotificationState(_ sender: UISwitch) {
        if sender.isOn {
            self.manager?.updateNotificationSettings("public/wall", sound: "default", alert: true)
        } else {
            self.manager?.updateNotificationSettings("public/wall", sound: "", alert: false)
        }
    }

    @IBAction func dissmisBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
}
