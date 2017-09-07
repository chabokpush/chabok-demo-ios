//
//  View+Animation.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

extension  UIView {

    func fade(inAnimation view: UIView, withDuration duration: Float) {
        view.alpha = 0.0
        //fade in
        UIView.animate(withDuration: TimeInterval(duration), delay: 0.15, options: .curveEaseIn, animations: {() -> Void in
            view.alpha = 1.0
        }) { _ in }
    }
    
    func fadeOutAnimation(_ view: UIView, withDuration duration: Float) {
        view.alpha = 1.0
        //fade out
        UIView.animate(withDuration: TimeInterval(duration), animations: {() -> Void in
            view.alpha = 0.0
        }) { _ in }
    }
    
    func fade(inAndFadeOutAnimation view: UIView, withDuration duration: Float) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {() -> Void in
            view.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {() -> Void in
                view.alpha = 0.0
            }) { _ in }
        })
    }

    
    
    func controlScaleAnimation(_ view: UIView, andToTransform toTransform: CGSize, andFromTransform fromTransform: CGSize) {
        view.transform = view.transform.scaledBy(x: toTransform.width, y: toTransform.height)
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            view.transform = view.transform.scaledBy(x: fromTransform.width, y: fromTransform.height)
        })
    }
    
    
}
