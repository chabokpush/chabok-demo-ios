//
//  Message.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/17/1394 AP.
//  Copyright © 1394 Farshad Ghafari. All rights reserved.
//

import Foundation
import CoreData
import AdpPushClient

extension Message {
    
    @NSManaged var createdTime: NSDate?
    @NSManaged var id: String?
    @NSManaged var data: NSObject?
    @NSManaged var message: String?
    @NSManaged var new: NSNumber?
    @NSManaged var receivedTime: NSDate?
    @NSManaged var senderId: String?
    @NSManaged var sent: String?
    @NSManaged var deliveryCount: NSNumber?
    
}


class Message: NSManagedObject {

    class func messageWithMessage(message: PushClientMessage, context:NSManagedObjectContext) -> Bool {
        print(message)
        let newMessage = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        
        if message.data != nil {
            newMessage.data = message.data
        }
        newMessage.sent = "send"
        newMessage.deliveryCount = 0
        newMessage.senderId = message.senderId
        newMessage.message = message.messageBody
        print(message.id)
        newMessage.id = message.id
        newMessage.createdTime = message.serverTime != nil ? message.serverTime : NSDate()
        newMessage.new = true
                
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = cal!.components([.Day , .Month, .Year ], fromDate: message.receivedTime)
        let newDate = cal!.dateFromComponents(components)
        newMessage.receivedTime = newDate
        
        do {
            try context.save()
            return true
        } catch {
            
        }
    
        return false

    }
    
    class func messageWithDeliveryId(delivery:DeliveryMessage, context:NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        let send = NSPredicate(format: "id == %@", delivery.messageId)
        fetchRequest.predicate = send
        
        if let fetchResult = (try? context.executeFetchRequest(fetchRequest)) as? [Message] {
            
            if fetchResult.count > 0 {
                
                for item in fetchResult{
                    let plus = Int(item.deliveryCount!) + 1 as NSNumber
                    item.setValue(plus, forKey: "deliveryCount")
                    do {
                        try context.save()
                    } catch {
                        
                    }
                }
                
                
            }
        }
        
    }

    
    class func messageWithSent(message:PushClientMessage, context:NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        let send = NSPredicate(format: "id == %@", message.sentId)
        fetchRequest.predicate = send
        
        if let fetchResult = (try? context.executeFetchRequest(fetchRequest)) as? [Message] {
            
            if fetchResult.count > 0 {
                
                for item in fetchResult{
                    item.setValue("sent", forKey: "sent")
                    do {
                        try context.save()
                    } catch {
                        
                    }
                }
                
                
            }
        }

    }
}
