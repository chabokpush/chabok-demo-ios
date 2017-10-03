//
//  DiscoveryViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit
import Lottie
import AdpPushClient

class DiscoveryViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: YellowGradientView!

    var timer = Timer()
    var manager = PushClientManager()
    
    var event = EventMessage()
    var msg = String()
    var found = Bool()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // lottie animation
        let animationView = LOTAnimationView(name: "search-ask_loop.json")
        animationView.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-125, y: (UIScreen.main.bounds.size.height/2)-125, width: 250, height: 250)
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()

        NotificationCenter.default.addObserver(self, selector: #selector(discoveryResualt), name: NSNotification.Name(rawValue: "discoveryDataStatusNotif"), object: nil)

    }
 
    func discoveryResualt(data: Notification) {
        
        event = data.userInfo!["data"] as! EventMessage
        msg = event.data["msg"] as! String
        found = event.data["found"] as! Bool
        
        print("\(found)")
        self.showResualt()

    }
    
    func showResualt()
    {

        if found == true {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "rewardViewID") as! RewardViewController
            newViewController.resualMessage = msg
            self.navigationController?.pushViewController(newViewController, animated: true)
            
            
        }else{
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "failedViewID") as! FailedViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        print("end digging")
    }
}
