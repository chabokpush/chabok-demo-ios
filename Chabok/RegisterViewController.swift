//
//  RegisterViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 ADP Digital Co. All rights reserved.
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

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }


    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    @IBAction func RegisterInChabok(_ sender: AnyObject) {
        
        var message: String = ""
        if familyName.text == "" {
            message = "نام خود را وارد کنید\n"
        }
        
        if email.text == "" || !email.text!.contains("@") {
            message += "ایمیل خود را وارد کنید"
        }
        
        if message.length > 0 {
            let alert = UIAlertController(title: "خطا",
                message: message,
                preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "باشه",
                style: UIAlertActionStyle.default,
                handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        
        self.manager = PushClientManager.default()
      
        if !self.manager.registerUser(email.text,channels: ["public/wall"]) {
            print("Error : \(self.manager.failureError)")
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.setValue(self.familyName.text, forKey: "name")
        defaults.synchronize()
        self.dismiss(animated: true, completion: nil)
   }
}
