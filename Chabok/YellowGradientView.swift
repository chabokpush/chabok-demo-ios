//
//  YellowGradientView.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/19/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class YellowGradientView: UIView {

    override  func awakeFromNib() {
        super.awakeFromNib()
        
        // Gradient
        let gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        
        let color1 = (#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).cgColor as CGColor
        let color2 = (#colorLiteral(red: 1, green: 0.8284607307, blue: 0.5395409145, alpha: 0.5089953785)).cgColor as CGColor
        
        gradient.colors = [color1, color2]
        gradient.locations = [0.0, 0.5 , 0.75 , 1.0]
        self.layer.addSublayer(gradient)
        
    }

}
