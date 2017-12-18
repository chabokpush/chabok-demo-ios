//
//  RateLimiting.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 7/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

extension NSObject {
    
    func throttle(_ action: Selector, withObject object: Any?, duration: TimeInterval) {
        let throttleData = UserDefaults.standard
        let lastCalled = throttleData.object(forKey: NSStringFromSelector(action)) as? Date
        if ((lastCalled == nil) || Date().timeIntervalSince(lastCalled!) >= duration) {
            throttleData.set(Date(), forKey: NSStringFromSelector(action))
            weak var weakSelf = self
            weakSelf?.perform(action, with: object)
        }
    }
    
    func debounce(_ action: Selector, withObject object: Any?, duration: TimeInterval) {
        weak var weakSelf = self
        NSObject.cancelPreviousPerformRequests(withTarget: weakSelf ?? "", selector: action, object: object)
        weakSelf?.perform(action, with: object, afterDelay: duration)
    }
    
}
