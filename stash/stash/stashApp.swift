//
//  stashApp.swift
//  stash
//
//  Created by Nikola on 16. 5. 2026..
//

import SwiftUI
import SwiftData

@main
struct StashApp: App {

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self, SpendingEntry.self])
    }
}
