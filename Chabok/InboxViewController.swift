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
    
    @IBOutlet weak var gradientView: UIView!
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
        if self.manager.userId == nil {
            ShowFirstView()
        }

        discoveryBtn.layer.cornerRadius = 45
        
        // Gradient
        let gradient = CAGradientLayer()
        
        gradient.frame = self.gradientView.bounds 
        
        let color1 = UIColor.clear
        let color2 = (#colorLiteral(red: 1, green: 0.831372549, blue: 0.5333333333, alpha: 1)).cgColor as CGColor
        
        gradient.colors = [color1, color2]
        gradient.locations = [0.0, 1.0 , 0.95 , 1.0]
        self.gradientView.layer.addSublayer(gradient)
        
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
        
        cell.inboxText.text = fetchMessage.message

        if (fetchMessage.data != nil) {
            let dataModel = DataModel(data: fetchMessage.data as! NSDictionary)
            if (dataModel.img != nil) {
                cell.inboxImage.isHidden = false
                cell.inboxImage.sd_setImage(with: URL(string: dataModel.img!), placeholderImage: UIImage(named:""))
                cell.inboxImageHeight.constant = (UIScreen.main.bounds.size.width) * 0.5
            }else{
                cell.inboxImage.isHidden = true
                cell.inboxImageHeight.constant = 0
            }
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let fetchMessage = self.fetchedResultsController.object(at: indexPath) as! InboxModel
        return String().cellHeightForMessage(fetchMessage.message!)
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

        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "discoveryViewID") as! DiscoveryViewController
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    // shake view and navigate to discovery
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake {
  
            self.publishCaptainStatusEvent()
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "discoveryViewID") as! DiscoveryViewController
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(newViewController, animated: true)
            
        }
    }
    
    func publishCaptainStatusEvent() {
        
        // send location and publish event
        let coreGeoLocation = self.manager.instanceCoreGeoLocation
        let lastLocation = coreGeoLocation?.lastLocation
        self.manager.publishEvent("captainStatus", data: ["status":"digging","lat":lastLocation?.coordinate.latitude ?? "","lng":lastLocation?.coordinate.longitude ?? ""])
    }
    
    func ShowFirstView() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let firstView = storyBoard.instantiateViewController(withIdentifier: "firstViewNavID")
        self.navigationController!.present(firstView, animated: true, completion: nil)
    }
}
