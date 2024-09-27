//
//  CodeGenerationAppApp.swift
//  CodeGenerationApp
//
//  Created by Omveer Panwar on 27/09/24.
//

//import SwiftUI
//
//import SwiftUI
//import CoreData
//
//@main
//struct YourAppNameApp: App {
//    
//    // Create the persistent container
//    let persistenceController = PersistenceController.shared
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//        }
//    }
//}
//
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    let container: NSPersistentContainer
//
//    // Initialize the Core Data stack
//    init() {
//        container = NSPersistentContainer(name: "Model")  // Ensure this matches your .xcdatamodeld file
//        container.loadPersistentStores { (description, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//    }
//}
//
import SwiftUI
import CoreData
import FirebaseCore

// AppDelegate for Firebase configuration
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure() // Configure Firebase
        return true
    }
}

@main
struct CodeGenerationAppApp: App {
    
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Create the persistent container
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// Core Data stack setup
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    // Initialize the Core Data stack
    init() {
        container = NSPersistentContainer(name: "Model")  // Ensure this matches your .xcdatamodeld file
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
