//
//  WasteEntry+CoreDataProperties.swift
//  Litrack-MC2
//
//  CoreData Entity Properties
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import Foundation
import CoreData

extension WasteEntry {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WasteEntry> {
        return NSFetchRequest<WasteEntry>(entityName: "WasteEntry")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var confidence: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var imageName: String?
}

extension WasteEntry : Identifiable {
    
}
