//
//  DashboardComponents.swift
//  stash
//
//  Supporting value types and small subviews used by DashboardView.
//

import SwiftUI

// MARK: - Models

enum PaydayTiming {
    case beginning, middle, end
}

struct SalaryBreakdown {
    let savingRatio: Double
    let fixedRatio: Double
    let freeRatio: Double
}

// MARK: - Bars

/// A simple two-layer progress capsule (track + filled portion).
struct ProgressTrack: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(tint)
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 4)
    }
}

/// A segmented bar showing the salary split into saving / fixed / free portions.
struct SegmentedBreakdownBar: View {
    let breakdown: SalaryBreakdown

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 2) {
                Capsule()
                    .fill(Color(hex: "#534AB7"))
                    .frame(width: proxy.size.width * breakdown.savingRatio)
                Capsule()
                    .fill(Color(hex: "#3C3489"))
                    .frame(width: proxy.size.width * breakdown.fixedRatio)
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: proxy.size.width * breakdown.freeRatio)
            }
        }
        .frame(height: 8)
    }
}
