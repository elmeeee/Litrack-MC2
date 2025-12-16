//
//  DataController.swift
//  Litrack-MC2
//
//  CoreData Stack Management
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    static let shared = DataController()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Litrack_MC2")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Create Sample Data
    func createSampleData() {
        let context = container.viewContext
        
        let wasteTypes = ["Plastic", "Can", "Glass"]
        
        for i in 0..<10 {
            let entry = WasteEntry(context: context)
            entry.id = UUID()
            entry.type = wasteTypes.randomElement() ?? "Plastic"
            entry.confidence = Double.random(in: 0.85...0.99)
            entry.timestamp = Date().addingTimeInterval(-Double(i) * 86400)
            entry.imageName = "sample_\(i)"
        }
        
        save()
    }
}
