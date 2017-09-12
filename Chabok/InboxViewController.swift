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

class InboxViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var inboxTableView: UITableView!
    @IBOutlet weak var discoveryBtn: UIButton!
    var manager = PushClientManager()

    let mCntxt = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext = mCntxt!
        
        let entity = NSEntityDescription.entity(forEntityName: "Message", in: managedObjectContext)
        let sort = NSSortDescriptor(key: "createdTime", ascending: true)
        let sortnew = NSSortDescriptor(key: "new", ascending: true)
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
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //        let sectionCount = self.fetchedResultsController.sections!.count;
        //        return sectionCount
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        let fetchInfo = self.fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        //        return fetchInfo[section].numberOfObjects
        return 5
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let fetchMessage = self.fetchedResultsController.object(at: indexPath) as! Message
        
        let cell:InboxTableViewCell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as! InboxTableViewCell!
        
        let card:InboxView = Bundle.main.loadNibNamed("InboxView", owner: self, options: nil)?[0] as! InboxView
//        card.frame = CGRect(x: 16, y: 16, width: UIScreen.main.bounds.size.width - 17, height: 173)
        
//        card.bodyMsg.text = fetchMessage.message
        
        
        var frame: CGRect? = cell.cornerView?.frame
        frame?.origin.x = 0
        frame?.origin.y = 0
        frame?.size.width -= 0
        frame?.size.height -= 0
        card.frame = frame!
 
        cell.cornerView.addSubview(card)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        let fetchMessage = self.fetchedResultsController.object(at: indexPath) as! Message
        //        return String().cellHeightForMessage(fetchMessage.message!)
        return 200
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        let storyBoard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "discoveryViewID") as! DiscoveryViewController
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    func ShowFirstView() {
        let firstView = self.storyboard?.instantiateViewController(withIdentifier: "firstViewID")
        self.navigationController!.present(firstView!, animated: true, completion: nil)
    }
}
