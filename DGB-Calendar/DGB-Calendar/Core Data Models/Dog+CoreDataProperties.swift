//
//  Dog+CoreDataProperties.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 11/1/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//
//

import Foundation
import CoreData


extension Dog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dog> {
        return NSFetchRequest<Dog>(entityName: "Dog")
    }

    @NSManaged public var age: String?
    @NSManaged public var breed: String?
    @NSManaged public var dogName: String?
    @NSManaged public var groomInterval: String?
    @NSManaged public var meds: String?
    @NSManaged public var personality: String?
    @NSManaged public var price: String?
    @NSManaged public var procedure: String?
    @NSManaged public var shampoo: String?
    @NSManaged public var vet: String?
    @NSManaged public var owner: Client?

}
