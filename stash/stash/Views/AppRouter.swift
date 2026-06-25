//
//  AppRouter.swift
//  stash
//
//  Drives the main tab selection so any screen can switch tabs.
//

import SwiftUI

enum AppTab: Hashable {
    case vault, goals, monthly, account
}

@Observable
@MainActor
final class AppRouter {
    var selectedTab: AppTab = .monthly
}
