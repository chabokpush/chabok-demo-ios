//
//  InfoViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/12/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    

    @IBAction func dismissBtnClick(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "avatarViewID") as! AvatarViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
        

    }
}
