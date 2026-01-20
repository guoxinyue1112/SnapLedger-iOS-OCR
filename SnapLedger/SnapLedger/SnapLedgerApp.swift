//
//  SnapLedgerApp.swift
//  SnapLedger
//
//  Created by 郭心月 on 1/20/26.
//

import SwiftUI

@main
struct SnapLedgerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
