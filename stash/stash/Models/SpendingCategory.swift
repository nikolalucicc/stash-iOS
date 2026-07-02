//
//  SpendingCategory.swift
//  stash
//
//  Categories the user logs day-to-day spending into.
//

import Foundation

enum SpendingCategory: String, CaseIterable, Identifiable {
    case food, transport, fun, shopping, health, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .food:      return String(localized: "spending.category.food")
        case .transport: return String(localized: "spending.category.transport")
        case .fun:       return String(localized: "spending.category.fun")
        case .shopping:  return String(localized: "spending.category.shopping")
        case .health:    return String(localized: "spending.category.health")
        case .other:     return String(localized: "spending.category.other")
        }
    }

    var icon: String {
        switch self {
        case .food:      return "fork.knife"
        case .transport: return "car.fill"
        case .fun:       return "gamecontroller.fill"
        case .shopping:  return "bag.fill"
        case .health:    return "cross.fill"
        case .other:     return "ellipsis.circle.fill"
        }
    }
}
