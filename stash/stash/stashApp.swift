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
                // Cards size their fields and buttons in fixed points, and the
                // balance is set at 48pt, so the largest accessibility steps
                // overflow rather than reflow. Honour the reader's setting up
                // to the first accessibility size and hold there.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
        .modelContainer(for: [
            UserProfile.self, FixedExpenseEntity.self, SavingsGoal.self,
            SpendingEntry.self, SpendingCategory.self
        ])
    }
}
