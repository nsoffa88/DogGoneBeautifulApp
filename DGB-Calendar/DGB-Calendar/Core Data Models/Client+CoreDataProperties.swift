//
//  Client+CoreDataProperties.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 11/1/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    @NSManaged public var address: String?
    @NSManaged public var clientName: String?
    @NSManaged public var email: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var referrals: String?
    @NSManaged public var referredBy: String?
    @NSManaged public var dogs: NSSet

}

// MARK: Generated accessors for dogs
extension Client {

    @objc(addDogsObject:)
    @NSManaged public func addToDogs(_ value: Dog)

    @objc(removeDogsObject:)
    @NSManaged public func removeFromDogs(_ value: Dog)

    @objc(addDogs:)
    @NSManaged public func addToDogs(_ values: NSSet)

    @objc(removeDogs:)
    @NSManaged public func removeFromDogs(_ values: NSSet)

}
