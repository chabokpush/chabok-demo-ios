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
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    let manager = PushClientManager.default()
    @IBOutlet weak var alertView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.hideView))
        self.view.addGestureRecognizer(tap)
        var notificationSetting = self.manager?.notificationSettings(for: "public/wall")
       
        if notificationSetting != nil {
            let alert = notificationSetting?["alert"]
            
            if alert as! Bool {
                self.notificationSwitch.setOn(true, animated: true)
            } else {
                self.notificationSwitch.setOn(false, animated: true)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fade(inAnimation: self.view, withDuration: 0.3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fadeOutAnimation(self.view, withDuration: 0.05)
    }
    
    func hideView() {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bview"), object: nil)
        
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
    
    
    func fade(inAnimation view: UIView, withDuration duration: Float) {
        view.alpha = 0.0
        //fade in
        UIView.animate(withDuration: TimeInterval(duration) , delay: 0.15, options: .curveEaseIn, animations: {() -> Void in
            view.alpha = 1.0
        }) { _ in }
    }
    
    func fadeOutAnimation(_ view: UIView, withDuration duration: Float) {
        view.alpha = 1.0
        //fade out
        UIView.animate(withDuration: TimeInterval(duration), animations: {() -> Void in
            view.alpha = 0.0
        }) { _ in }
    }
}
