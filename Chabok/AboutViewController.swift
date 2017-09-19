//
//  AboutViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 ADP Digital Co. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var openUrl: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "درباره چابک"
        openUrl.layer.cornerRadius = 23
        
        let NavButton = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: self, action: #selector(AboutViewController.navigateToSetting))
        self.navigationItem.rightBarButtonItem  = NavButton
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func navigateToSetting() {
        

        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let vc: SettingViewController? = storyBoard.instantiateViewController(withIdentifier:  "settingViewID") as? SettingViewController
        self.present(vc!, animated: true, completion: nil)

    }
    @IBAction func openUrl(_ sender: Any) {
        if let url = URL(string: "http://www.chabokpush.com") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func calling(_ sender: Any) {
        if let url = URL(string: "tel://02189678") {
            UIApplication.shared.openURL(url)
        }
    }
}
