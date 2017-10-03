//
//  FailedViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit
import Lottie

class FailedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // lottie animation
        let animationView = LOTAnimationView(name: "Failed.json")
        animationView.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-125, y: (UIScreen.main.bounds.size.height/2)-200, width: 250, height: 250)
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()
        
    }

    @IBAction func dismissBtnClick(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)

    }
}
