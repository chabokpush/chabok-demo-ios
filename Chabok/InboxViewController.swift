//
//  InboxViewController.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/15/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit
import CoreData
import AdpPushClient
import SDWebImage

class InboxViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var inboxTableView: UITableView!
    @IBOutlet weak var discoveryBtn: UIButton!
    @IBOutlet weak var leftBarButtonIcon: UIBarButtonItem!
    var manager = PushClientManager()
    
    var lastIndexPath : IndexPath! {
        
        let sectionsAmount = self.inboxTableView.numberOfSections - 1
        let rowAmount = self.inboxTableView.numberOfRows(inSection: sectionsAmount)
        let lastIndexPath = IndexPath(row: rowAmount - 1, section: 0)
        return lastIndexPath
        
    }
    
    let mCntxt = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext = mCntxt!
        
        let entity = NSEntityDescription.entity(forEntityName: "Inbox", in: managedObjectContext)
        let sort = NSSortDescriptor(key: "createdTime", ascending: false)
        let sortnew = NSSortDescriptor(key: "new", ascending: false)
        let req : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager = PushClientManager.default()
        if self.manager.userId == nil || self.manager.userId.contains("@") {
            ShowFirstView()
        }
        
        discoveryBtn.layer.cornerRadius = 45
        
        inboxTableView.register(UINib(nibName: "InboxView", bundle: nil), forCellReuseIdentifier: "inboxCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PushClientManager.resetBadge()
    }
    
    // tableView methodes
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = self.fetchedResultsController.sections!.count;
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fetchInfo = self.fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return fetchInfo[section].numberOfObjects
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fetchMessage = self.fetchedResultsController.object(at: indexPath) as! InboxModel
        let cell :InboxTableViewCell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as! InboxTableViewCell!
        
        if (fetchMessage.data != nil) {
            let data = fetchMessage.data!;
            
            let dataModel = DataModel(data: data as! NSDictionary)
            if (dataModel.imgUrl != nil) {
                cell.inboxImage.isHidden = false
                cell.inboxImage.sd_setImage(with: URL(string: dataModel.imgUrl!), placeholderImage: UIImage(named:""))
                cell.inboxImageHeight.constant = (UIScreen.main.bounds.size.width) * 0.5
            }else{
                cell.inboxImage.isHidden = true
                cell.inboxImageHeight.constant = 0
            }
        } else {
            cell.inboxImage.isHidden = true
            cell.inboxImageHeight.constant = 0
        }
        
        cell.inboxText.text = fetchMessage.message
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    //MARK: - NSFetchResultController
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.inboxTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.inboxTableView.deleteRows(at: [indexPath!], with: .automatic)
            break
        case .insert:
            self.inboxTableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .move:
            self.inboxTableView.deleteRows(at: [indexPath!], with: .automatic)
            self.inboxTableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .update:
            self.inboxTableView.reloadRows(at: [indexPath!], with: .automatic)
            break
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            self.inboxTableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        case .insert:
            self.inboxTableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        case .update:
            self.inboxTableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        default:
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.inboxTableView.beginUpdates()
    }
    
    @IBAction func aboutChabok(_ sender: UIBarButtonItem) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "aboutChabokID") as! AboutViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func goToChatView(_ sender: UIBarButtonItem) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "msgViewID") as! MessageViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(newViewController, animated: true)
        
    }
    
    @IBAction func discoveryBtnClick(_ sender: Any) {
        
        self.publishCaptainStatusEvent()
    }
    
    // shake view and navigate to discovery
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake {
            self.publishCaptainStatusEvent()
        }
    }
    
    func publishCaptainStatusEvent() {
        
        // send location and publish event
        let coreGeoLocation = self.manager.instanceCoreGeoLocation
        let lastLocation = coreGeoLocation?.lastLocation
        let authrization = coreGeoLocation?.authrizationState()
        
        if lastLocation == nil {
            showAlert("دسترسی به لوکیشن امکان پذیر نیست")
            return
        }else if (authrization == .notDetermined) || (authrization == .notDetermined) || (authrization == .denied){
             showAlert("دسترسی به لوکیشن خود را روشن کنید")
            return
        }
        
        self.manager.publishEvent("captainStatus", data: ["status":"digging","lat":lastLocation?.coordinate.latitude ?? "","lng":lastLocation?.coordinate.longitude ?? ""])
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "discoveryViewID") as! DiscoveryViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showAlert(_ message: String) {
        
        let alert = UIAlertController(title: title ,message:message,preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "باشه",style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Change font of the title and message
        let titleFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "IRANSans(FaNum)", size: 20)! ]
        let messageFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "IRANSans(FaNum)", size: 14)! ]
        
        let attributedTitle = NSMutableAttributedString(string: "خطا", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: message, attributes: messageFont)
        
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func ShowFirstView() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let firstView = storyBoard.instantiateViewController(withIdentifier: "firstViewNavID")
        self.navigationController!.present(firstView, animated: true, completion: nil)
    }
}
