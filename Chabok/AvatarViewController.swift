//
//  AvatarViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/12/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit

class AvatarViewController: UIViewController {
    
    var imageWasSelected = UIImage()
    var selectedAvatarIndex = NSInteger()
    @IBOutlet weak var nextPageBtn: CornerButton!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var selectionBtn: CornerButton!
    
    var avatarSelectedArr : NSArray = [#imageLiteral(resourceName: "avatar1selected"),#imageLiteral(resourceName: "avatar2selected"),#imageLiteral(resourceName: "avatar3selected"),#imageLiteral(resourceName: "avatar4selected")]
    var avatarNotselectedArr : NSArray = [#imageLiteral(resourceName: "avatar1"),#imageLiteral(resourceName: "avatar2"),#imageLiteral(resourceName: "avatar3"),#imageLiteral(resourceName: "avatar4")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextPageBtn.isHidden = true
        selectionBtn.isHidden = false

        nextPageBtn.setTitle("کاپیتان چابکت رو انتخاب کن ", for: .normal)
        nextPageBtn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        nextPageBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
    
    @IBAction func avatar1Click(_ sender: Any) {
        selectAvatar(0)
    }
    
    @IBAction func avatar2Click(_ sender: Any) {
        selectAvatar(1)
    }
    
    @IBAction func avatar3Click(_ sender: Any) {
        selectAvatar(2)
    }
    
    @IBAction func avatar4Click(_ sender: Any) {
        selectAvatar(3)
    }
    

    @IBAction func nextPageBtnClick(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "registerViewID") as! RegisterViewController
        newViewController.image = imageWasSelected
        newViewController.avatarIndex = selectedAvatarIndex
        self.navigationController?.pushViewController(newViewController, animated: true)
    }

    func resetAvatarSelection()  {

        for (index,view) in avatarView.subviews.enumerated(){
            
            let btn = view as? UIButton
            btn?.setImage((avatarNotselectedArr[index] as? UIImage), for: .normal)

        }
    }
    
    func selectAvatar(_ index:NSInteger) {
        
        resetAvatarSelection()
        
        nextPageBtn.isHidden = false
        selectionBtn.isHidden = true
        
        nextPageBtn.setTitle("برو بعدی", for: .normal)
        nextPageBtn.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.6274509804, blue: 0, alpha: 1)
        nextPageBtn.setTitleColor(#colorLiteral(red: 0.4705882353, green: 0.2941176471, blue: 0.168627451, alpha: 1), for: .normal)
        
        let btn = avatarView.subviews[index] as! UIButton
        btn.setImage(avatarSelectedArr[index] as? UIImage, for: .normal)

        imageWasSelected = (avatarSelectedArr[index] as? UIImage)!
        selectedAvatarIndex = index
        
    }

}
