//
//  AppDelegate.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 ADP Digital Co. All rights reserved.
//

import UIKit
import CoreData
import AdpPushClient
import AudioToolbox



@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,PushClientManagerDelegate,CoreGeoLocationDelegate {
    
    var window: UIWindow?
    var manager = PushClientManager()
    // use for location
    var locationManager = CoreGeoLocation()
    
    
    class func applicationId() -> String{
        return "chabok-demo"
    }
    
    class func applicationVersion() -> String{
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String);
    }
    
    class func userNameAndPassword() -> (userName : String, password : String, apikey : String){
        return ("chabokdemo","chabokdemo","1bd0c7e26ab5bf18ec940d8f7216ce39972aea9b")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        PushClientManager.setDevelopment(false)
        PushClientManager.resetBadge()
        self.manager = PushClientManager.default()
        self.manager.addDelegate(self)
        
        self.manager.instanceCoreGeoLocation.add(self)
        
        self.manager.application(application, didFinishLaunchingWithOptions: launchOptions)

        let userPass = AppDelegate.userNameAndPassword()
        self.manager.registerApplication(AppDelegate.applicationId(),
                                         apiKey : userPass.apikey,userName:userPass.userName ,password:userPass.password )
        
        if let userId = self.manager.userId {
            if !self.manager.registerUser(userId) {
                print("Error : \(self.manager.failureError)")
            }
        }
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "IRANSans(FaNum)", size: 16)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        PushClientManager.resetBadge()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        PushClientManager.resetBadge()
        print(application.applicationIconBadgeNumber)
    }
    
    // Notification Handling
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.manager.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.manager.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        
    }

    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        self.manager.application(application, didRegister: notificationSettings)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        self.manager.application(application, didReceive: notification)
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "8.0") && SYSTEM_VERSION_LESS_THAN(version: "10.0")) && application.applicationState == .active{
            return
        }
        let topic = notification.userInfo?["topic"] as! String
        notificationNavigation(topic)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Hook and Handle New Remote Notification
        // must be use for remote payloads
        // note : use this apis over
        manager.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        
        let message = userInfo["aps"] as! NSDictionary
        let category = message["category"] as! String
        notificationNavigation(category)
        print(">>>> didReceiveRemoteNotification\(userInfo)")
    }
    
    func application(_ application: UIApplication,
                              supportedInterfaceOrientationsForWindow window: UIWindow?) -> Int{
        return UIDeviceOrientation.faceDown.rawValue;
    }
    func notificationNavigation(_ topic: String) {
        var viewController = UIViewController();
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Demo", bundle: nil)
        
        if topic.contains("captain"){
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "InboxViewID") as! InboxViewController
        } else {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "msgViewID") as! MessageViewController
        }
        
        let currentViewContoller = getCurrentViewController()
        currentViewContoller.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        currentViewContoller.navigationController?.pushViewController(viewController, animated: true)
    }
  
    func getCurrentViewController() -> UIViewController {
        return (self.window!.rootViewController?.childViewControllers.last)!;
    }
    
    func pushClientManagerUILocalNotificationDidReceivedMessage(_ message: PushClientMessage) {
        if message.senderId != nil && message.senderId == self.manager.userId {
            return
        }
        
        let currentViewContoller = getCurrentViewController();
        if currentViewContoller.isKind(of: InboxViewController.self) && message.topicName.contains("captain") {
            return
        } else if currentViewContoller.isKind(of: MessageViewController.self) && message.topicName.contains("public/wall") {
            return
        } else if currentViewContoller.isKind(of: MessageViewController.self) && message.topicName.contains("\(self.manager.userId!)/\(self.manager.getRegistrationId()!)") {
            return
        }
        self.throttle(#selector(showLocalNotificationWithRateLimit), withObject: message, duration: 2)
    }
    
    func showLocalNotificationWithRateLimit(_ message : PushClientMessage) {
        let application = UIApplication.shared
        let localNotification = UILocalNotification()
        localNotification.userInfo = ["topic":message.topicName]
        
        localNotification.alertBody = message.messageBody
        if message.data == nil {
            localNotification.soundName = "n.aiff"
        }else{
            if message.data.keys.contains("type") {
                localNotification.soundName = (message.data["type"]) as! Int > 10  ? "d.aiff" : "w.aiff"
            }else{
                localNotification.soundName = "n.aiff"
            }
        }
        localNotification.applicationIconBadgeNumber = application.applicationIconBadgeNumber
        application.presentLocalNotificationNow(localNotification)
        
    }
    
    func pushClientManagerDidRegisterUser(_ registration: Bool) {
        
        print(registration)
    }
    
    
    func pushClientManagerDidFailRegisterUser(_ error: Error!) {
        print(error)
        print(self.manager.failureError)
    }
    
    func pushClientManagerDidChangedServerConnectionState() {
        if self.manager.connectionState == .connectedState {
            print("we are connected")
            self.manager.enableEventDelivery("treasure")
            
        }
    }
    
    func pushClientManagerDidReceivedEventMessage(_ eventMessage: EventMessage!) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "discoveryDataStatusNotif"), object: nil, userInfo: ["data":eventMessage])
        print("pushClientManagerDidReceivedEventMessage\(eventMessage.data)")
        
    }
    
    func pushClientManagerDidReceivedMessage(_ message: PushClientMessage!) {
        
        if message.senderId != self.manager.userId {
            if message.messageBody == nil {
                return
            }
            DispatchQueue.main.async(execute: {
                if message.topicName.contains("captain"){
                    
                    if InboxModel.messageWithMessage(message, context: self.managedObjectContext!) == true {
                        
                        if (self.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "8.0") && self.SYSTEM_VERSION_LESS_THAN(version: "10.0")){
                            AudioServicesPlayAlertSound(1009)
                        }
                    }
                }else{
                    if  Message.messageWithMessage(message, context: self.managedObjectContext!) == true {
                        if (self.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "8.0") && self.SYSTEM_VERSION_LESS_THAN(version: "10.0")){
                            AudioServicesPlayAlertSound(1007)
                        }
                    }
                }
            })
            
        } else {
            DispatchQueue.main.async(execute: {
                Message.messageWithSent(message, context: self.managedObjectContext!)
            })
        }
    }

    func receivedLocationUpdates(_ locations: [CLLocation]) {
        
        let lastLocation = locations.last
        let data : NSDictionary = ["lat":lastLocation?.coordinate.latitude ?? 0,"lng" : lastLocation?.coordinate.longitude ?? 0,"ts": (Date().timeIntervalSince1970)*1000]
        
        self.manager.publishEvent("geo", data: data as! [AnyHashable : Any], live: false, stateful: true)
        print("background location >>>>>>\(data)")
    }
    
    func pushClientManagerDidReceivedDelivery(_ delivery: DeliveryMessage!) {
        
        DispatchQueue.main.async(execute: {
            Message.messageWithDeliveryId(delivery: delivery, context: self.managedObjectContext!)
            
        })
    }
    
    func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
    }
    
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending

    }
    
    func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
    }
    
    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
    }
 
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = Bundle.main.url(forResource: "Chabok", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("chabok.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption:true,
                                                                                                                      NSInferMappingModelAutomaticallyOption:true])
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            
            var dict = [String: AnyObject]()
            
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func save(_ moc:NSManagedObjectContext) {
        do {
            try moc.save()
        } catch {
            print(error)
        }
        
    }
   
}

