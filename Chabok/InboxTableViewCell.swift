//
//  InboxTableViewCell.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/19/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var inboxImage: UIImageView!
    @IBOutlet weak var inboxText: UITextView!
    @IBOutlet weak var inboxImageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageFrameView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cornerView.layer.cornerRadius = 10
        imageFrameView.layer.cornerRadius = 10;
    }

}
