//
//  AboutViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 ADP Digital Co. All rights reserved.
//

import UIKit
import Lottie

class AboutViewController: UIViewController {
    
    @IBOutlet weak var openUrl: UIButton!
    @IBOutlet weak var animationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "درباره چابک"
        openUrl.layer.cornerRadius = 23
        
        let NavButton = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: self, action: #selector(AboutViewController.navigateToSetting))
        self.navigationItem.rightBarButtonItem  = NavButton
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // lottie animation
        let animationView = LOTAnimationView(name: "chabok.json")
        animationView.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-125, y: (UIScreen.main.bounds.size.height/2)-320, width: 250, height: 250)
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()
    }
    
    func navigateToSetting() {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let vc: SettingViewController? = storyBoard.instantiateViewController(withIdentifier:  "settingViewID") as? SettingViewController
//        self.present(vc!, animated: true, completion: nil)
        vc?.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc!, animated: true)
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
