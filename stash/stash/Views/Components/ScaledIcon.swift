//
//  ScaledIcon.swift
//  stash
//
//  Symbols and emoji sized in points stay put when the reader enlarges text,
//  leaving icons stranded beside type that has grown around them. This scales
//  them the same way, from the same point size.
//

import SwiftUI

private struct ScaledIconModifier: ViewModifier {

    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight

    init(size: CGFloat, weight: Font.Weight) {
        self._size = ScaledMetric(wrappedValue: size, relativeTo: .body)
        self.weight = weight
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight))
    }
}

extension View {
    /// Sizes a symbol or emoji at `size` points, scaling with Dynamic Type.
    func iconSize(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(ScaledIconModifier(size: size, weight: weight))
    }
}

/// A square that grows with the type inside it — icon badges and avatars.
struct ScaledSquare: ViewModifier {

    @ScaledMetric private var side: CGFloat

    init(_ side: CGFloat) {
        self._side = ScaledMetric(wrappedValue: side, relativeTo: .body)
    }

    func body(content: Content) -> some View {
        content.frame(width: side, height: side)
    }
}

extension View {
    /// A `side`×`side` frame that scales with Dynamic Type.
    func scaledSquare(_ side: CGFloat) -> some View {
        modifier(ScaledSquare(side))
    }
}

extension View {
    /// Keeps a headline amount on one line, shrinking it if the type has grown.
    /// Wrapping turns "70.800" into "70.8" above "00", which reads as a
    /// different number entirely.
    func amountLine() -> some View {
        self.lineLimit(1).minimumScaleFactor(0.4)
    }
}
