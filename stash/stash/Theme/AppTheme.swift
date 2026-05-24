import SwiftUI

// MARK: - Colors

extension Color {
    // Surface
    static let surfaceContainerLowest  = Color(hex: "#0e0d14")
    static let surfaceContainerLow     = Color(hex: "#1c1b21")
    static let surfaceContainer        = Color(hex: "#201f25")
    static let surfaceContainerHigh    = Color(hex: "#2a2930")
    static let surfaceContainerHighest = Color(hex: "#35343b")
    static let surfaceBright           = Color(hex: "#3a383f")
    static let surfaceDim              = Color(hex: "#131319")
    static let surfaceVariant          = Color(hex: "#35343b")
    static let surfaceTint             = Color(hex: "#c5c0ff")
    static let appSurface              = Color(hex: "#131319")
    static let appBackground           = Color(hex: "#131319")

    // On-surface
    static let onSurface               = Color(hex: "#e5e1ea")
    static let onSurfaceVariant        = Color(hex: "#c8c4d4")
    static let onBackground            = Color(hex: "#e5e1ea")

    // Primary
    static let appPrimary              = Color(hex: "#c5c0ff")
    static let primaryFixed            = Color(hex: "#e4dfff")
    static let primaryFixedDim         = Color(hex: "#c5c0ff")
    static let primaryContainer        = Color(hex: "#8c84eb")
    static let onPrimary               = Color(hex: "#2a1c84")
    static let onPrimaryFixed          = Color(hex: "#140067")
    static let onPrimaryFixedVariant   = Color(hex: "#41379b")
    static let onPrimaryContainer      = Color(hex: "#23127d")
    static let inversePrimary          = Color(hex: "#5951b4")

    // Secondary
    static let appSecondaryColor       = Color(hex: "#c5c0ff")
    static let secondaryFixed          = Color(hex: "#e3dfff")
    static let secondaryFixedDim       = Color(hex: "#c5c0ff")
    static let secondaryContainer      = Color(hex: "#3f35a3")
    static let onSecondaryColor        = Color(hex: "#28188c")
    static let onSecondaryFixed        = Color(hex: "#140067")
    static let onSecondaryFixedVariant = Color(hex: "#3f35a3")
    static let onSecondaryContainer    = Color(hex: "#b2acff")

    // Tertiary
    static let appTertiary             = Color(hex: "#c5c0ff")
    static let tertiaryFixed           = Color(hex: "#e4dfff")
    static let tertiaryFixedDim        = Color(hex: "#c5c0ff")
    static let tertiaryContainer       = Color(hex: "#8d86e0")
    static let onTertiary              = Color(hex: "#2b2278")
    static let onTertiaryFixed         = Color(hex: "#150264")
    static let onTertiaryFixedVariant  = Color(hex: "#423a8f")
    static let onTertiaryContainer     = Color(hex: "#241971")

    // Error
    static let appError                = Color(hex: "#ffb4ab")
    static let errorContainer          = Color(hex: "#93000a")
    static let onError                 = Color(hex: "#690005")
    static let onErrorContainer        = Color(hex: "#ffdad6")

    // Outline
    static let appOutline              = Color(hex: "#928f9d")
    static let outlineVariant          = Color(hex: "#474552")

    // Inverse
    static let inverseSurface          = Color(hex: "#e5e1ea")
    static let inverseOnSurface        = Color(hex: "#313036")

    // Brand accent (#7F77DD — used for buttons, active progress)
    static let accent                  = Color(hex: "#7F77DD")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double(int >> 16) / 255
        let g = Double(int >> 8 & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Typography

extension Font {
    static let noteStyle          = Font.custom("Inter", size: 12).weight(.regular)
    static let labelCapsStyle     = Font.custom("Inter", size: 11).weight(.medium)
    static let sectionHeaderStyle = Font.custom("Inter", size: 18).weight(.medium)
    static let displayValStyle    = Font.custom("Inter", size: 24).weight(.medium)
    static let inputValStyle      = Font.custom("Inter", size: 15).weight(.regular)
    static let screenTitleStyle   = Font.custom("Inter", size: 22).weight(.medium)
    static let displayLgStyle     = Font.custom("Inter", size: 36).weight(.medium)
    static let bodyStyle          = Font.custom("Inter", size: 14).weight(.regular)
    static let labelSmStyle       = Font.custom("Inter", size: 10).weight(.regular)
    static let heroNumStyle       = Font.custom("Inter", size: 48).weight(.medium)
    static let navTitleStyle      = Font.custom("Inter", size: 16).weight(.medium)
    static let secondaryStyle     = Font.custom("Inter", size: 13).weight(.regular)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat               = 4
    static let sm: CGFloat               = 8
    static let base: CGFloat             = 8
    static let gutter: CGFloat           = 12
    static let md: CGFloat               = 16
    static let lg: CGFloat               = 24
    static let xl: CGFloat               = 32
    static let containerPadding: CGFloat = 20
}

// MARK: - Border Radius

enum Radius {
    static let `default`: CGFloat = 4
    static let lg: CGFloat        = 8
    static let xl: CGFloat        = 12
    static let full: CGFloat      = 9999
}
