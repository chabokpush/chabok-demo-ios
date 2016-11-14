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
class AppDelegate: UIResponder, UIApplicationDelegate,PushClientManagerDelegate {

    var window: UIWindow?
    var manager = PushClientManager()

    
    class func applicationId() -> String{
        return "YOUR_APPID"
    }
    
    class func applicationVersion() -> String{
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String);
    }
    
    class func userNameAndPassword() -> (userName : String, password : String, apikey : String){
        return ("SDK_USERNAME","SDK_PASSWORD","YOUR_APIKEY")
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        PushClientManager.setDevelopment(true)
        PushClientManager.resetBadge()
        self.manager = PushClientManager.default()
        self.manager.addDelegate(self)
        
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
    }
    
    
    func pushClientManagerDidRegisterUser(_ registration: Bool) {
        
        print(registration)
    }
    
    
    func pushClientManagerDidFailRegisterUser(_ error: Error!) {
        print(error)
        print(self.manager.failureError)
    }

    
    func pushClientManagerDidReceivedMessage(_ message: PushClientMessage!) {

        if message.senderId != self.manager.userId {
            if message.messageBody == nil {
                return
            }
            DispatchQueue.main.async(execute: {
                if  Message.messageWithMessage(message, context: self.managedObjectContext!) == true {
                    AudioServicesPlayAlertSound(1007)
                }
            })
            
        } else {
             DispatchQueue.main.async(execute: {
                Message.messageWithSent(message, context: self.managedObjectContext!)
            })
        }

    }
    
    
    func pushClientManagerDidReceivedDelivery(_ delivery: DeliveryMessage!) {

        DispatchQueue.main.async(execute: {
            Message.messageWithDeliveryId(delivery, context: self.managedObjectContext!)
        })
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
    
    func save(_ moc:NSManagedObjectContext) {
        do {
            try moc.save()
        } catch {
            print(error)
        }
        
    }
    


}

