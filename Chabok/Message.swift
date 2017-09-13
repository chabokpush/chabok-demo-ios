//
//  Message.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/17/1394 AP.
//  Copyright © 1394 ADP Digital Co. All rights reserved.
//

import Foundation
import CoreData
import AdpPushClient

extension Message {
    
    @NSManaged var createdTime: Date?
    @NSManaged var id: String?
    @NSManaged var data: NSObject?
    @NSManaged var message: String?
    @NSManaged var new: NSNumber?
    @NSManaged var receivedTime: Date?
    @NSManaged var senderId: String?
    @NSManaged var sent: String?
    @NSManaged var deliveryCount: NSNumber?
    @NSManaged var topic: String?
    
}


class Message: NSManagedObject {
    
    class func messageWithMessage(_ message: PushClientMessage, context:NSManagedObjectContext) -> Bool {
        print(message)
        let newMessage = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        
        if message.data != nil {
            newMessage.data = message.data as NSObject?
        }
//        newMessage.topic = message.topicName
        newMessage.sent = "send"
        newMessage.deliveryCount = 0
        newMessage.senderId = message.senderId
        newMessage.message = message.messageBody
        print(message.id)
        newMessage.id = message.id
        newMessage.createdTime = message.serverTime != nil ? message.serverTime : Date()
        newMessage.new = true
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (cal as NSCalendar).components([.day , .month, .year ], from: message.receivedTime)
        let newDate = cal.date(from: components)
        newMessage.receivedTime = newDate
        
        do {
            try context.save()
            return true
        } catch {
            
        }
        
        return false
        
    }
    
    class func messageWithDeliveryId(_ delivery:DeliveryMessage, context:NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let send = NSPredicate(format: "id == %@", delivery.messageId)
        fetchRequest.predicate = send
        
        if let fetchResult = (try? context.fetch(fetchRequest)) as? [Message] {
            
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
    
    
    class func messageWithSent(_ message:PushClientMessage, context:NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let send = NSPredicate(format: "id == %@", message.sentId)
        fetchRequest.predicate = send
        
        if let fetchResult = (try? context.fetch(fetchRequest)) as? [Message] {
            
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
