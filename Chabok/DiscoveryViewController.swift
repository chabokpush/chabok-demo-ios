//
//  DiscoveryViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class DiscoveryViewController: UIViewController {

    @IBOutlet weak var percentLbl: UILabel!
    @IBOutlet weak var percentProgress: UIProgressView!
    @IBOutlet weak var discoveryImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        percentProgress.transform = percentProgress.transform.scaledBy(x: 1, y: 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
