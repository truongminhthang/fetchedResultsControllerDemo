//
//  PersonMO+CoreDataProperties.swift
//  fetchedResultsController
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PersonMO {

    @NSManaged var lastName: String?
    @NSManaged var firstName: String?
    @NSManaged var creationDate: NSTimeInterval
    @NSManaged var department: DeparmentMO?

}
