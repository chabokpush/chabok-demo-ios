//
//  DiscoveryViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit
import Lottie

class DiscoveryViewController: UIViewController {

    @IBOutlet weak var backgroundView: YellowGradientView!
    @IBOutlet weak var percentLbl: UILabel!
    @IBOutlet weak var percentProgress: UIProgressView!
    @IBOutlet weak var discoveryImage: UIImageView!
    var poseDuration = 10
    var indexProgressBar = 1
    var currentPoseIndex = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        discoveryImage.layer.cornerRadius = 75
        percentProgress.transform = percentProgress.transform.scaledBy(x: 1, y: 7)
        percentProgress.layer.cornerRadius = 8
        percentProgress.clipsToBounds = true
   
        // initialise the display
        percentProgress.progress = 0.0
        // display the first pose
        getNextPoseData()
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DiscoveryViewController.setProgressBar), userInfo: nil, repeats: true)
        
        // lottie animation
        let animationView = LOTAnimationView(name: "kiss.json")
        animationView.frame = CGRect(x: 10, y: 30, width: 300, height: 300)
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()
    
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
        if indexProgressBar == poseDuration
        {
            getNextPoseData()
            
            // reset the progress counter
            indexProgressBar = 1
        }
        
        // update the display
        // use poseDuration - 1 so that you display 20 steps of the the progress bar, from 0...19
        percentProgress.progress = Float(indexProgressBar) / Float(poseDuration - 1)
        percentLbl.text = String(format: "%ld٪",indexProgressBar*10)

        // increment the counter
        indexProgressBar += 1
    }
}
