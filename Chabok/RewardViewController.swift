//
//  RewardViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit
import Lottie
import AdpPushClient

class RewardViewController: UIViewController {

    @IBOutlet weak var msgLabel: UILabel!
    var resualMessage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // lottie animation
        let animationView = LOTAnimationView(name: "Reward.json")
        animationView.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-150, y: (UIScreen.main.bounds.size.height/2)-230, width: 300, height: 300)
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()
    
        self.msgLabel.text = resualMessage
    }

    @IBAction func dismissBtnClick(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)

    }
}
