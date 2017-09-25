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
    @IBOutlet weak var percentLbl: UILabel!
    @IBOutlet weak var percentProgress: UIProgressView!
    var poseDuration = 11
    var indexProgressBar = 1
    var currentPoseIndex = 0
    var timer = Timer()
    var manager = PushClientManager()
    
    var event = EventMessage()
    var msg = String()
    var found = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        percentProgress.transform = percentProgress.transform.scaledBy(x: 1, y: 7)
        percentProgress.layer.cornerRadius = 8
        percentProgress.clipsToBounds = true
        
        // initialise the display
        percentProgress.progress = 0.0
        // display the first pose
        getNextPoseData()
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(setProgressBar), userInfo: nil, repeats: true)
        
        // lottie animation
        let animationView = LOTAnimationView(name: "kiss.json")
        animationView.frame = CGRect(x: 10, y: 30, width: 300, height: 300)
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(discoveryResualt), name: NSNotification.Name(rawValue: "discoveryDataStatusNotif"), object: nil)
        print("digging")
    }
    
    func discoveryResualt(data: Notification) {
        
        event = data.userInfo!["data"] as! EventMessage
        msg = event.data["msg"] as! String
        found = event.data["found"] as! Bool
        
        print("\(found)")
    }
    
    func getNextPoseData()
    {
        // do next pose stuff
        if currentPoseIndex == 1 {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        print(currentPoseIndex)
    }
    
    func setProgressBar()
    {
        if indexProgressBar == 11
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
        
        // update the display
        // use poseDuration - 1 so that you display 20 steps of the the progress bar, from 0...19
        percentProgress.progress = Float(indexProgressBar) / Float(poseDuration - 1)
        percentLbl.text = String(format: "%ld٪",indexProgressBar*10)
        
        // increment the counter
        indexProgressBar += 1
    }
}
