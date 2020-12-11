//
//  RecentSearch+CoreDataProperties.swift
//  
//
//  Created by Jathinesh Kottem on 11/12/20.
//
//

import Foundation
import CoreData


extension RecentSearch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentSearch> {
        return NSFetchRequest<RecentSearch>(entityName: "RecentSearch")
    }

    @NSManaged public var item: String?

}
