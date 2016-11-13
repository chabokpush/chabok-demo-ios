//
//  AppDelegate.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 Farshad Ghafari. All rights reserved.
//

import UIKit
import CoreData
import AdpPushClient
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,PushClientManagerDelegate {

    var window: UIWindow?
    var manager = PushClientManager()

    
    class func applicationId() -> String{
        return "YOUR_APP_ID"
    }
    
    class func applicationVersion() -> String{
        return (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String);
    }
    
    class func userNameAndPassword() -> (userName : String, password : String){
        return ("YOUR_SDK_USERNAME","YOUR_SDK_PASSWORD")
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        PushClientManager.setDevelopment(true)
        PushClientManager.resetBadge()
        self.manager = PushClientManager.defaultManager()
        self.manager.addDelegate(self)
        
        self.manager.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let userPass = AppDelegate.userNameAndPassword()
        if self.manager.registerApplication(AppDelegate.applicationId(),
            userName:userPass.userName, password:userPass.password) {
                
                if let userId = self.manager.userId {
                    if !self.manager.registerUser(userId) {
                        print("Error : \(self.manager.failureError)")
                        
                    }
                }
        }
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "IRANSans(FaNum)", size: 16)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        return true
    }
    
    
    func applicationDidEnterBackground(application: UIApplication) {
        PushClientManager.resetBadge()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        PushClientManager.resetBadge()
        print(application.applicationIconBadgeNumber)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        self.manager.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.manager.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        
    }
    
    
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        self.manager.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        self.manager.application(application, didReceiveLocalNotification: notification)
    }
    
    
    func pushClientManagerDidRegisterUser(registration: Bool) {
        
        print(registration)
    }
    
    
    func pushClientManagerDidFailRegisterUser(error: NSError!) {
        print(error)
        print(self.manager.failureError)
    }

    
    func pushClientManagerDidReceivedMessage(message: PushClientMessage!) {

        if message.senderId != self.manager.userId {
            if message.messageBody == nil {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                if  Message.messageWithMessage(message, context: self.managedObjectContext!) == true {
                    AudioServicesPlayAlertSound(1007)
                }
            })
            
        } else {
             dispatch_async(dispatch_get_main_queue(), {
                Message.messageWithSent(message, context: self.managedObjectContext!)
            })
        }

    }
    
    
    func pushClientManagerDidReceivedDelivery(delivery: DeliveryMessage!) {

        dispatch_async(dispatch_get_main_queue(), {
            Message.messageWithDeliveryId(delivery, context: self.managedObjectContext!)
        })
    }

    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
      
        let modelURL = NSBundle.mainBundle().URLForResource("Chabok", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ChabokPushDemo.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: [NSMigratePersistentStoresAutomaticallyOption:true,
                NSInferMappingModelAutomaticallyOption:true])
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            
            var dict = [String: AnyObject]()
            
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            NSLog("Unresolved error \(error), \(error!.userInfo)")
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
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func save(moc:NSManagedObjectContext) {
        do {
            try moc.save()
        } catch {
            print(error)
        }
        
    }
    


}

