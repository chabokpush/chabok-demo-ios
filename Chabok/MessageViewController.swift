//
//  MessageViewController.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 Farshad Ghafari. All rights reserved.
//

import UIKit
import CoreData
import AdpPushClient

let KOffset:CGFloat = 219
var keyboardshow: Bool = false

class MessageViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate{
    let mCntxt = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var lastIndexPath : NSIndexPath! {
        
        let sectionsAmount = self.tableView.numberOfSections - 1
        let rowAmount = self.tableView.numberOfRowsInSection(sectionsAmount)
        let lastIndexPath = NSIndexPath(forRow: rowAmount - 1, inSection: 0)
        return lastIndexPath
        
    }
    var _fetchedResultsController: NSFetchedResultsController?
    var fetchedResultsController: NSFetchedResultsController {
        
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext = mCntxt!
        
        let entity = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext)
        let sort = NSSortDescriptor(key: "createdTime", ascending: true)
        let sortnew = NSSortDescriptor(key: "new", ascending: true)
        let req = NSFetchRequest()
        req.entity = entity
        req.sortDescriptors = [sort,sortnew]
        req.fetchBatchSize = 10
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        self._fetchedResultsController = aFetchedResultsController
        
        
        var e: NSError?
        do {
            try self._fetchedResultsController!.performFetch()
        } catch let error as NSError {
            e = error
            print("fetch error: \(e!.localizedDescription)")
            abort();
        }
        
        return self._fetchedResultsController!
    }

    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageInputView: UIView!
    @IBOutlet var messageInputViewLayout: NSLayoutConstraint!
    @IBOutlet var buttonMessage: UIButton!
    @IBOutlet var textfieldMessage: UITextField!
    
    var textIntry: UITextField!
    var manager = PushClientManager()
    
    
    
    
    //MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.showsVerticalScrollIndicator = false
        
        buttonMessage.layer.borderWidth = 1
        buttonMessage.layer.borderColor = UIColor.fromRGB(0x00325d).CGColor
        buttonMessage.layer.cornerRadius = 3
        buttonMessage.addTarget(self, action: "publishMessage", forControlEvents: .TouchUpInside)
        
        textfieldMessage.layer.borderWidth = 1
        textfieldMessage.layer.borderColor = UIColor.fromRGB(0x525d7a).CGColor
        textfieldMessage.layer.cornerRadius = 3
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
        textfieldMessage.leftView = paddingView
        textfieldMessage.rightView = paddingView
        textfieldMessage.leftViewMode = .Always
        textfieldMessage.rightViewMode = .Always
        
        self.manager = PushClientManager.defaultManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: "hide")
        self.tableView.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if lastIndexPath.row > 0 {
            self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
        }
    }
    
    
    //MARK: - table view delegates and data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let sectionCount = self.fetchedResultsController.sections!.count;
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fetchInfo = self.fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return fetchInfo[section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let fetchMessage = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Message
        return String().cellHeightForMessage(fetchMessage.message!)
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let fetchMessage = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Message

        var sender:String = "چابک رسان"
        if let senderName = fetchMessage.data?.valueForKey("name") {
            sender = senderName as! String
        }

        if sender == NSUserDefaults.standardUserDefaults().valueForKey("name") as! String {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ChabokTableCell
            cell.msg.text = fetchMessage.message
            cell.avatarName.text = sender
            cell.deliveryCounter.text = fetchMessage.deliveryCount?.stringValue
            if fetchMessage.sent == "send" {
                cell.sendImg.image = UIImage(named: "tick")
            } else {
                cell.sendImg.image = UIImage(named: "tick-green")
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.calendar = NSCalendar(calendarIdentifier: "persian")
            dateFormatter.locale = NSLocale(localeIdentifier: "fa_IR")
            dateFormatter.dateFormat = "HH:mm YYYY/MM/dd"
            let time =  dateFormatter.stringFromDate(fetchMessage.createdTime!)
            cell.recieveTime.text = time
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("uCell", forIndexPath: indexPath) as! ChabokUserTableCell
            cell.msg.text  = fetchMessage.message
            cell.avatarName.text = sender
            let dateFormatter = NSDateFormatter()
            dateFormatter.calendar = NSCalendar(calendarIdentifier: "persian")
            dateFormatter.locale = NSLocale(localeIdentifier: "fa_IR")
            dateFormatter.dateFormat = "HH:mm YYYY/MM/dd"
            let time =  dateFormatter.stringFromDate(fetchMessage.createdTime!)
            
            cell.recieveTime.text = time
            return cell
        }
        
    }

    //MARK: - NSFetchResultController
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            break
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            break
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            break
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            break

        }
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            break
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            break
        case .Update:
            self.tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            break
        default:
            break
        }

    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    

    func hide () {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)
    }

    func keyboardWillShow(notification:NSNotification) {

        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        print(keyboardSize?.height)
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height , 0.0)
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10 , 0.0)
        self.tableView.scrollIndicatorInsets = contentInsets
        if lastIndexPath.row > 0 {
            self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
        }
        
        let curve = UIViewAnimationCurve(rawValue: notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        
        setViewMoveUp(true,originY: keyboardSize!.height,curve: curve , duration:duration)

    }
    
    
    func keyboardWillHide(notification:NSNotification)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10 , 0.0)//UIEdgeInsetsZero
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        
        
        let curve = UIViewAnimationCurve(rawValue: notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        setViewMoveUp(false, curve: curve, duration: duration)
    }
  
    
    func publishMessage () {
        self.manager = PushClientManager.defaultManager()
        if self.textfieldMessage.text != "" {
            let defaults = NSUserDefaults.standardUserDefaults()
            let message = PushClientMessage(message: self.textfieldMessage.text!, withData: ["name":defaults.valueForKey("name")!], topic: "public/wall")
            
            let appcontext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            dispatch_async(dispatch_get_main_queue(), {
                Message.messageWithMessage(message, context: appcontext!)
            })
            self.manager.publish(message)
            self.textfieldMessage.text = ""
            
        }
        
    }
    
    func setViewMoveUp(moveUp:Bool,originY:CGFloat = 0,curve:UIViewAnimationCurve, duration:Double) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
      
        self.messageInputViewLayout.constant = originY
        self.view.layoutIfNeeded()

        UIView.commitAnimations()
    }

}

class ChabokUserTableCell: UITableViewCell {
    
    @IBOutlet var recieveTime: UILabel!
    @IBOutlet var msgBackground: UIView!
    @IBOutlet var avatarView: UIView!
    @IBOutlet var msg: UILabel!
    @IBOutlet var avatarName: UILabel!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.msgBackground.layer.cornerRadius = 3
        self.avatarView.layer.cornerRadius = 13
        self.avatarView.layer.borderWidth = 1.5
        self.avatarView.layer.borderColor = UIColor.fromRGB(0x65527a).CGColor
    }
}

class ChabokTableCell: UITableViewCell {
    
    @IBOutlet var sendImg: UIImageView!
    @IBOutlet var recieveTime: UILabel!
    @IBOutlet var deliveryCounter: UILabel!
    @IBOutlet var avatarView: UIView!
    @IBOutlet var msg: UILabel!
    @IBOutlet var msgBackground: UIView!
    @IBOutlet var avatarName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    
        
        self.msgBackground.layer.cornerRadius = 3
        self.avatarView.layer.cornerRadius = 13
        self.avatarView.layer.borderWidth = 1.5
        self.avatarView.layer.borderColor = UIColor.fromRGB(0x525d7a).CGColor
    }
}
