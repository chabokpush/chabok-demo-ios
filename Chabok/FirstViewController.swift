//
//  FirstViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/12/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var startBtn: CornerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startBtn.layer.cornerRadius = 43;
        
    }
    
    @IBAction func startBtnClick(_ sender: UIButton) {
       
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "infoViewID") as! InfoViewController
        self.navigationController?.pushViewController(newViewController, animated: true)

    }


}
