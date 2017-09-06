//
//  GradientView.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/13/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override  func awakeFromNib() {
        super.awakeFromNib()
        
        let gradient = CAGradientLayer()

        // 2
        gradient.frame = self.bounds
        
        // 3
        let color1 = (#colorLiteral(red: 0.08397377282, green: 0.5688710809, blue: 0.9887786508, alpha: 1)).cgColor as CGColor
        let color2 = (#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).cgColor as CGColor
        
        gradient.colors = [color1, color2]
        
        // 4
        gradient.locations = [0.0, 1, 0.5, 1.0]
        
        // 5
        self.layer.addSublayer(gradient)
  
    }
}
