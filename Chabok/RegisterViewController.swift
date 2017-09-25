//
//  RegisterViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 ADP Digital Co. All rights reserved.
//

import UIKit
import AdpPushClient

class RegisterViewController: UIViewController,UITextFieldDelegate {
    
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
        
        familyName.delegate = self
        phone.delegate = self
        
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
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
    
//    private func textField(_ textField: phone.text, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if (textField.text as NSString?) != nil {
//            
//            let persianPhoneNumber: String = persianNumberToEnglish(mobileNumber:phone.text!)
//            let phoneNum: String = (persianPhoneNumber as NSString).replacingCharacters(in: NSRange(location: 0, length: 1), with: "98")
//            self.manager.registerUser(phoneNum)
//        }
//        return true
//    }
    
    @IBAction func backBtnClick(_ sender: AnyObject) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func RegisterInChabok(_ sender: AnyObject) {
        
        var message: String = ""
        let actionTitle: String = "خطا"
        
        if (familyName.text?.characters.count)! < 3 {
            message = "نام خود را وارد کنید\n"
        }
        if !isOnlyNumber(input: phone.text!) || (phone.text?.characters.count)! < 11 {
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
        
        var englishPhoneNumber: String = persianNumberToEnglish(mobileNumber:phone.text!)
//        let indexOne = englishPhoneNumber.remove(at: englishPhoneNumber.index(before:englishPhoneNumber.startIndex))
//
//        var phoneNum = String()
        
//        print(">>>>>>>>>>>>>>>>indexOne\(String(describing: indexOne))")
        
//        englishPhoneNumber = (englishPhoneNumber as NSString).replacingCharacters(in: NSRange(location: 1, length: 0), with: "98")
     
        
        
        self.manager = PushClientManager.default()
        
        let userInfo =  ["name":self.familyName.text ?? "چابک رسان" ,"avatarIdx": self.avatarIndex,"userId": englishPhoneNumber] as [String : Any]
        self.manager.userInfo = userInfo
        
        
        self.manager.enableLocationOnLaunch = true
        
        let registrationState = self.manager.registerUser(englishPhoneNumber, channels: ["public/wall"]) {
            (isRegistered, userId, error) in
         
        }
        
        if !registrationState {
            print("Error : \(self.manager.failureError)")
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.setValue(self.familyName.text, forKey: "name")
        defaults.setValue(self.avatarIndex, forKey: "avatarIdx")
        defaults.setValue(englishPhoneNumber, forKey: "userId")
        defaults.synchronize()
        
        
        // Navigate to Inbox
        //            let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        //            let newViewController = storyBoard.instantiateViewController(withIdentifier: "InboxViewNavID") as! UINavigationController
        //            let vc: UINavigationController? = storyBoard.instantiateViewController(withIdentifier: "InboxViewNavID") as? UINavigationController
        //            self.navigationController?.pushViewController(newViewController, animated: true)
        performSegue(withIdentifier: "goToInbox", sender: self)
        
        
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
            f.origin.y = (-1 * (height / 4.5))
            self.view.frame = f
        })
    }
    
    func keyboardWillHide() {
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            var f: CGRect = self.view.frame
            f.origin.y = 0.0
            self.view.frame = f
        })
    }
    
    func isOnlyNumber(input: String) -> Bool {
        
        let cs = CharacterSet(charactersIn: "0123456789۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩").inverted
        var filtered: String = (input.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        if (filtered.characters.count ) == input.length {
            return true
        }
        return false
    }
    
    func persianNumberToEnglish(mobileNumber: String) -> String {
        let Formatter = NumberFormatter()
        let locale = NSLocale(localeIdentifier: "en")
        Formatter.locale = locale as Locale
        let newNum = Formatter.number(from: mobileNumber)
        if mobileNumber.hasPrefix("0") || mobileNumber.hasPrefix("۰") || mobileNumber.hasPrefix("٠") {
            return "0\(Formatter.string(from: newNum!)!)"
        }
        
        return Formatter.string(from: newNum!)!
    }
    


}
