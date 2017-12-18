//
//  CornerView.swift
//  Chabok
//
//  Created by Parvin Mehhrabani on 9/16/17.
//  Copyright © 2017 Farshad Ghafari. All rights reserved.
//

import UIKit

class CornerView: UIView {

    override  func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10;
        
        //       let maskPath = UIBezierPath(roundedRect: self.bounds,
        //                                    byRoundingCorners: [.topLeft,.topRight,.bottomRight],
        //                                   cornerRadii: CGSize(width: 5.0, height: UIScreen.main.bounds.size.height))
        //       let maskLayer = CAShapeLayer()
        //       maskLayer.path = maskPath.cgPath
        //        self.layer.mask = maskLayer
        
    }

}
