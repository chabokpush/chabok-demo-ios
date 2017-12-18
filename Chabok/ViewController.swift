//
//  ViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 ADP Digital Co. All rights reserved.
//

import UIKit
import AdpPushClient


class ViewController: UIViewController {
    var pageMenu : FAGHPageMenu?
    var manager = PushClientManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.manager = PushClientManager.default()
        if self.manager.userId == nil {
            ShowRegisterView()
        }

        var controllerArray : [UIViewController] = []
        
        let chabokTitle = UILabel()
        chabokTitle.text = "چابک رسان"
        chabokTitle.frame.size.width = 100
        chabokTitle.frame.size.height = 30
        chabokTitle.textColor = UIColor.fromRGB(0x003a6b)
        chabokTitle.font = UIFont.setFamilyFontFromAppFont(size: 20)
        chabokTitle.frame.origin.x = (self.view.frame.size.width - chabokTitle.frame.size.width) / 2
        chabokTitle.frame.origin.y = 30
        self.view.addSubview(chabokTitle)
        

        let connectionStatus = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        connectionStatus.textColor = UIColor.lightGray
        connectionStatus.font = UIFont.setFamilyFontFromAppFont(size: 12)
        connectionStatus.textAlignment = .left
        connectionStatus.text = "آفلاین"
        connectionStatus.frame.origin.x = 30
        connectionStatus.frame.origin.y = 30

        
        self.view.addSubview(connectionStatus)

        self.manager.serverConnectionStateHandler = {() -> Void in
            if self.manager.connectionState == .connectedState {
                 connectionStatus.text = "آنلاین"
                
            } else if self.manager.connectionState == .disconnectedState ||
                self.manager.connectionState == .disconnectedErrorState {
                    connectionStatus.text = "آفلاین"
            } else {
                connectionStatus.text = "در حال ارتباط"
            
            }
        }
        
        
        let messageView = self.storyboard?.instantiateViewController(withIdentifier: "msg")
        messageView?.title = "پیام رسان"
        controllerArray.append(messageView!)
        
        let aboutView =  self.storyboard?.instantiateViewController(withIdentifier: "abt")
        aboutView?.title = "درباره چابک"
        controllerArray.append(aboutView!)

        let parameters: [FAGHPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.scrollMenuBackgroundColor()),
            .viewBackgroundColor(UIColor.white),
            .selectionIndicatorColor(UIColor.selectionIndicatorColor()),
            .bottomMenuHairlineColor(UIColor.bottomMenuHairlineColor()),
            .selectedMenuItemLabelColor(UIColor.selectedMenuItemLabelColor()),
            .unselectedMenuItemLabelColor(UIColor.unselectedMenuItemLabelColor()),
            .selectionIndicatorHeight(4.0),
            .menuItemFont(UIFont.setFamilyFontFromAppFont(size: 17)),
            .menuHeight(30.0),
            .menuItemWidth(85),
            .menuMargin(50.0),
            .menuItemSeparatorRoundEdges(true),
            .centerMenuItems(true)]
        
        pageMenu = FAGHPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 70, width: self.view.frame.width, height: self.view.frame.height - 70), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
        self.addChildViewController(pageMenu!)
        pageMenu?.didMove(toParentViewController: self)
    
    }
    
    func ShowRegisterView() {
        let regView = self.storyboard?.instantiateViewController(withIdentifier: "reg")
        self.navigationController!.present(regView!, animated: true, completion: nil)
    }
 

}

