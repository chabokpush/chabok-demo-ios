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
        
        familyName.delegate = self as? UITextFieldDelegate
        phone.delegate = self as? UITextFieldDelegate

    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        familyName.becomeFirstResponder()
        phone.becomeFirstResponder()

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
        let userPass = AppDelegate.userNameAndPassword()
        if self.manager.registerApplication(AppDelegate.applicationId(), apiKey: userPass.apikey,
                                            userName:userPass.userName, password:userPass.password) {
            
            if !self.manager.registerUser(phone.text,channels: ["public/wall"]) {
                print("Error : \(self.manager.failureError)")
                return
            }
            
            let defaults = UserDefaults.standard
            defaults.setValue(self.familyName.text, forKey: "name")
            defaults.synchronize()

            // Navigate to Inbox
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
//            let newViewController = storyBoard.instantiateViewController(withIdentifier: "InboxViewNavID") as! UINavigationController
//            let vc: UINavigationController? = storyBoard.instantiateViewController(withIdentifier: "InboxViewNavID") as? UINavigationController

//            self.navigationController?.pushViewController(newViewController, animated: true)
            performSegue(withIdentifier: "goToInbox", sender: self)
            
        }
    }
    
    // TextField Methodes
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideAvatarImage()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        showAvatarImage()
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        showAvatarImage()
    }
    
    
    // Image Animation
    
    func hideAvatarImage() {
        
        view.controlScaleAnimation(avatarImage, andToTransform: CGSize(width: 1, height: 1), andFromTransform: CGSize(width: 0.001, height: 0.001))
        keyboardWillShow()
        
    }
    
    func showAvatarImage() {
        
        view.controlScaleAnimation(avatarImage, andToTransform: CGSize(width: 0.001, height: 0.001), andFromTransform: CGSize(width: 1000000, height: 1000000))
        keyboardWillHide()
    }
    
    
    // keyboard movements
    
    func keyboardWillShow() {
        let height: CGFloat = UIScreen.main.bounds.size.height
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            var f: CGRect = self.view.frame
            f.origin.y = (-1 * (height / 4.5)) + 64.0
            self.view.frame = f
        })
    }
    
    func keyboardWillHide() {
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            var f: CGRect = self.view.frame
            f.origin.y = 64.0
            self.view.frame = f
        })
    }
}
