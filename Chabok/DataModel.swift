//
//  DataModel.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/21/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class DataModel: NSObject {

    var img: String?
    var location: String?
    var text: String?
    
    init(data: NSDictionary) {
        super.init()
        self.img = data.object(forKey: "img") as? String
        self.location = data.object(forKey: "location") as? String
        self.text = data.object(forKey: "text") as? String
    }
}
