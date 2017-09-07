//
//  InboxViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController {

    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var discoveryBtn: CornerButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        
        // 2
        gradient.frame = self.gradientView.bounds
        
        // 3
        let color1 = (#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)).cgColor as CGColor
        let color2 = (#colorLiteral(red: 0.9215686275, green: 0.6274509804, blue: 0, alpha: 1)).cgColor as CGColor
        
        gradient.colors = [color1, color2]
        
        // 4
        gradient.locations = [0.0, 1, 0.5, 1.0]
        
        // 5
        self.gradientView.layer.addSublayer(gradient)

    }

}
