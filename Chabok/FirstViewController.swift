//
//  FirstViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/12/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startBtnClick(_ sender: UIButton) {
//        
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "infoViewID") as! InfoViewController
//        self.navigationController?.pushViewController(newViewController, animated: true)
//        self.present(newViewController, animated: true, completion: nil)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "infoViewID") as! InfoViewController
        navigationController?.pushViewController(vc, animated: true)
        
        
//       self.performSegue(withIdentifier: "first2info", sender: nil)


    }


}
