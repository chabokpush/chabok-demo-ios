//
//  InboxModel.swift
//  Chabok
//
//  Created by Parvin Mehrabani on 6/22/1396 AP.
//  Copyright © 1396 Farshad Ghafari. All rights reserved.
//

import UIKit
import CoreData
import AdpPushClient

extension InboxModel {
    
    @NSManaged var createdTime: Date?
    @NSManaged var data: NSObject?
    @NSManaged var message: String?
    @NSManaged var receivedTime: Date?
    @NSManaged var new: NSNumber?
    @NSManaged var id: String?

}

class InboxModel: NSManagedObject {

    
    class func messageWithMessage(_ inbox: PushClientMessage, context:NSManagedObjectContext) -> Bool {
        print(inbox)
        let newMessage = NSEntityDescription.insertNewObject(forEntityName: "Inbox", into: context) as! InboxModel
        
        if inbox.data != nil {
            newMessage.data = inbox.data as NSObject?
        }
        newMessage.new = true
        newMessage.message = inbox.messageBody
        newMessage.id = inbox.id
        newMessage.createdTime = inbox.serverTime != nil ? inbox.serverTime : Date()

        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (cal as NSCalendar).components([.day , .month, .year ], from: inbox.receivedTime)
        let newDate = cal.date(from: components)
        newMessage.receivedTime = newDate
        
        
        do {
            try context.save()
            return true
        } catch {
            
        }
        
        return false
        
    }
    
}
