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
    let mCntxt = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var lastIndexPath : IndexPath! {
        
        let sectionsAmount = self.tableView.numberOfSections - 1
        let rowAmount = self.tableView.numberOfRows(inSection: sectionsAmount)
        let lastIndexPath = IndexPath(row: rowAmount - 1, section: 0)
        return lastIndexPath
        
    }
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext = mCntxt!
        
        let entity = NSEntityDescription.entity(forEntityName: "Message", in: managedObjectContext)
        let sort = NSSortDescriptor(key: "createdTime", ascending: true)
        let sortnew = NSSortDescriptor(key: "new", ascending: true)
        let req = NSFetchRequest<NSFetchRequestResult>()
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
        self.title = "دیوار چابک"
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10 , 0.0)
        buttonMessage.layer.borderWidth = 1
        buttonMessage.layer.borderColor = UIColor.fromRGB(0x00325d).cgColor
        buttonMessage.layer.cornerRadius = 3
        buttonMessage.addTarget(self, action: #selector(MessageViewController.publishMessage), for: .touchUpInside)
        
        textfieldMessage.layer.borderWidth = 1
        textfieldMessage.layer.borderColor = UIColor.fromRGB(0x525d7a).cgColor
        textfieldMessage.layer.cornerRadius = 3
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
        textfieldMessage.leftView = paddingView
        textfieldMessage.rightView = paddingView
        textfieldMessage.leftViewMode = .always
        textfieldMessage.rightViewMode = .always
        
        self.manager = PushClientManager.default()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MessageViewController.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MessageViewController.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MessageViewController.hide))
        self.tableView.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if lastIndexPath.row > 0 {
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    
    //MARK: - table view delegates and data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = self.fetchedResultsController.sections!.count;
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fetchInfo = self.fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return fetchInfo[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let fetchMessage = self.fetchedResultsController.object(at: indexPath) as! Message
        return String().cellHeightForMessage(fetchMessage.message!)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let fetchMessage = self.fetchedResultsController.object(at: indexPath) as! Message
        
        var sender:String = "چابک رسان"
        if let senderName = fetchMessage.data?.value(forKey: "name") {
            sender = senderName as! String
        }
        
        if sender == UserDefaults.standard.value(forKey: "name") as! String {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChabokTableCell
            cell.msg.text = fetchMessage.message
            cell.avatarName.text = sender
            cell.deliveryCounter.text = fetchMessage.deliveryCount?.stringValue
            if fetchMessage.sent == "send" {
                cell.sendImg.image = UIImage(named: "tick")
            } else {
                cell.sendImg.image = UIImage(named: "tick-green")
            }
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .persian)
            dateFormatter.locale = Locale(identifier: "fa_IR")
            dateFormatter.dateFormat = "HH:mm YYYY/MM/dd"
            let time =  dateFormatter.string(from: fetchMessage.createdTime! as Date)
            cell.recieveTime.text = time
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "uCell", for: indexPath) as! ChabokUserTableCell
            cell.msg.text  = fetchMessage.message
            cell.avatarName.text = sender
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .persian)
            dateFormatter.locale = Locale(identifier: "fa_IR")
            dateFormatter.dateFormat = "HH:mm YYYY/MM/dd"
            let time =  dateFormatter.string(from: fetchMessage.createdTime! as Date)
            
            cell.recieveTime.text = time
            return cell
        }
        
    }
    
    //MARK: - NSFetchResultController
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            break
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
            break
            
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        case .update:
            self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        default:
            break
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    
    func hide () {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        print(keyboardSize?.height)
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height , 0.0)
        self.tableView.scrollIndicatorInsets = contentInsets
        if lastIndexPath.row > 0 {
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
        
        let curve = UIViewAnimationCurve(rawValue: (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).intValue)!
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        
        setViewMoveUp(true,originY: keyboardSize!.height,curve: curve , duration:duration)
        
    }
    
    
    func keyboardWillHide(_ notification:Notification)
    {
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        
        let curve = UIViewAnimationCurve(rawValue: (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).intValue)!
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        setViewMoveUp(false, curve: curve, duration: duration)
    }
    
    
    func publishMessage () {
        self.manager = PushClientManager.default()
        if self.textfieldMessage.text != "" {
            let defaults = UserDefaults.standard
            var message:PushClientMessage!
            message = PushClientMessage(message: self.textfieldMessage.text!, withData: ["name":defaults.value(forKey: "name")!], topic: "public/wall")
            message.alertText = "\(defaults.value(forKey: "name")!):\(self.textfieldMessage.text!)"
            let appcontext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            DispatchQueue.main.async(execute: {
                Message.messageWithMessage(message, context: appcontext!)
            })
            self.manager.publish(message)
            self.textfieldMessage.text = ""
            
        }
        
    }
    
    func setViewMoveUp(_ moveUp:Bool,originY:CGFloat = 0,curve:UIViewAnimationCurve, duration:Double) {
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
        //   self.avatarView.layer.cornerRadius = 13
        //    self.avatarView.layer.borderWidth = 1.5
        //  self.avatarView.layer.borderColor = UIColor.fromRGB(0x65527a).CGColor
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
        //        self.avatarView.layer.cornerRadius = 13
        //        self.avatarView.layer.borderWidth = 1.5
        //        self.avatarView.layer.borderColor = UIColor.fromRGB(0x525d7a).CGColor
    }
}
