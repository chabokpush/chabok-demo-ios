//
//  RegisterViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 Farshad Ghafari. All rights reserved.
//

import UIKit
import AdpPushClient

class RegisterViewController: UIViewController {
    @IBOutlet var familyName: ChabokTextField!
    @IBOutlet var company: ChabokTextField!
    @IBOutlet var email: ChabokTextField!
    var manager = PushClientManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let tap = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tap)
    }


    func hideKeyboard() {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)
    }
    
    @IBAction func RegisterInChabok(sender: AnyObject) {
        
        var message: String = ""
        if familyName.text == "" {
            message = "نام خود را وارد کنید\n"
        }
        
        if email.text == "" || !email.text!.containsString("@") {
            message += "ایمیل خود را وارد کنید"
        }
        
        if message.length > 0 {
            let alert = UIAlertController(title: "خطا",
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "باشه",
                style: UIAlertActionStyle.Default,
                handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        
        self.manager = PushClientManager.defaultManager()
        let userPass = AppDelegate.userNameAndPassword()
        if self.manager.registerApplication(AppDelegate.applicationId(),
            userName:userPass.userName, password:userPass.password) {
                
                if !self.manager.registerUser(email.text,channels: ["public/wall"]) {
                    print("Error : \(self.manager.failureError)")
                    return
                }
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setValue(self.familyName.text, forKey: "name")
                defaults.synchronize()
                self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
