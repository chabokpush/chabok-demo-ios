//
//  ViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 Farshad Ghafari. All rights reserved.
//

import UIKit
import AdpPushClient


class ViewController: UIViewController {
    var pageMenu : FAGHPageMenu?
    var manager = PushClientManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.manager = PushClientManager.defaultManager()
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
        

        let connectionStatus = UILabel()
        connectionStatus.textColor = UIColor.lightGrayColor()
        connectionStatus.font = UIFont.setFamilyFontFromAppFont(size: 12)
        connectionStatus.text = "آفلاین"
        connectionStatus.sizeToFit()
        connectionStatus.frame.origin.x = chabokTitle.frame.origin.x - 40
        connectionStatus.frame.origin.y = 40

        
        self.view.addSubview(connectionStatus)

        self.manager.serverConnectionStateHandler = {() -> Void in
            if self.manager.connectionState == .ConnectedState {
            } else if self.manager.connectionState == .DisconnectedState ||
                self.manager.connectionState == .DisconnectedErrorState {
                    connectionStatus.text = "آفلاین"
            } else {
                connectionStatus.text = "آنلاین"
                //
            }
        }
        
        
        let messageView = self.storyboard?.instantiateViewControllerWithIdentifier("msg")
        messageView?.title = "پیام رسان"
        controllerArray.append(messageView!)
        
        let aboutView =  self.storyboard?.instantiateViewControllerWithIdentifier("abt")
        aboutView?.title = "درباره چابک"
        controllerArray.append(aboutView!)

        let parameters: [FAGHPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.scrollMenuBackgroundColor()),
            .ViewBackgroundColor(UIColor.whiteColor()),
            .SelectionIndicatorColor(UIColor.selectionIndicatorColor()),
            .BottomMenuHairlineColor(UIColor.bottomMenuHairlineColor()),
            .SelectedMenuItemLabelColor(UIColor.selectedMenuItemLabelColor()),
            .UnselectedMenuItemLabelColor(UIColor.unselectedMenuItemLabelColor()),
            .SelectionIndicatorHeight(4.0),
            .MenuItemFont(UIFont.setFamilyFontFromAppFont(size: 17)),
            .MenuHeight(30.0),
            .MenuItemWidth(85),
            .MenuMargin(50.0),
            .MenuItemSeparatorRoundEdges(true),
            .CenterMenuItems(true)]
        
        pageMenu = FAGHPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 70, self.view.frame.width, self.view.frame.height - 70), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
        self.addChildViewController(pageMenu!)
        pageMenu?.didMoveToParentViewController(self)
    
    }
    
    func ShowRegisterView() {
        let regView = self.storyboard?.instantiateViewControllerWithIdentifier("reg")
        self.navigationController!.presentViewController(regView!, animated: true, completion: nil)
    }
 

}

