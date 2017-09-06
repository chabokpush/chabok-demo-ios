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

    var image = UIImage()
    var avatarIndex = NSInteger()
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var familyName: CornerTextField!
    @IBOutlet weak var phone: CornerTextField!
    
    var manager = PushClientManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImage.image = image
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    @IBAction func backBtnClick(_ sender: AnyObject) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func RegisterInChabok(_ sender: AnyObject) {
        
        var message: String = ""
        let actionTitle: String = "خطا"

        if familyName.text == "" && (familyName.text?.length)! < 2 {
            message = "نام خود را وارد کنید\n"
        }
        if phone.text == ""  && (phone.text?.length)! < 11{
            message += "شماره تماس خود را وارد کنید"
        }
        
        if message.length > 0 {
            let alert = UIAlertController(title: actionTitle,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert)
        
            
            alert.addAction(UIAlertAction(title: "باشه",
                style: UIAlertActionStyle.default,
                handler: nil))
 
            
            
            // Change font of the title and message
            let titleFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "IRANSans(FaNum)", size: 20)! ]
            let messageFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "IRANSans(FaNum)", size: 14)! ]

            let attributedTitle = NSMutableAttributedString(string: "خطا", attributes: titleFont)
            let attributedMessage = NSMutableAttributedString(string: message, attributes: messageFont)

            alert.setValue(attributedTitle, forKey: "attributedTitle")
            alert.setValue(attributedMessage, forKey: "attributedMessage")

            self.present(alert, animated: true, completion: nil)

            return
        }
        
        
        self.manager = PushClientManager.default()
      
        if !self.manager.registerUser(phone.text,channels: ["public/wall"]) {
            print("Error : \(self.manager.failureError)")
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.setValue(self.familyName.text, forKey: "name")
        defaults.synchronize()
        self.dismiss(animated: true, completion: nil)
   }
}
