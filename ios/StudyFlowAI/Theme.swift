import SwiftUI

/// Central design system for StudyFlow AI — "Study Night" palette.
/// Dark-first, calm, content-first with a single indigo accent.
enum Theme {
    // Palette (hard constraints)
    static let background = Color(hex: 0x101014)
    static let surface = Color(hex: 0x1A1A22)
    static let surfaceRaised = Color(hex: 0x22222C)
    static let accent = Color(hex: 0x8B7CFF)
    static let accentSoft = Color(hex: 0xEDEBFF)
    static let text = Color(hex: 0xECECF2)
    static let textSecondary = Color(hex: 0x9A9AA8)
    static let textTertiary = Color(hex: 0x6C6C7A)
    static let hairline = Color(hex: 0x2C2C38)

    // Semantic states (kept inside palette family)
    static let success = Color(hex: 0x5BD6A6)
    static let warning = Color(hex: 0xF2C55C)
    static let danger = Color(hex: 0xF2788C)

    // Corner radii
    static let radiusSmall: CGFloat = 10
    static let radiusMedium: CGFloat = 16
    static let radiusLarge: CGFloat = 24

    // Subject accent tints (derived, still indigo-leaning family + restrained states)
    static func subjectColor(_ name: String) -> Color {
        switch name.lowercased() {
        case "math": return accent
        case "science": return success
        case "english": return Color(hex: 0xF2A65C)
        case "history": return Color(hex: 0xC97CFF)
        default: return accent
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Reusable surface styling

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16
    var radius: CGFloat = Theme.radiusMedium
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
    }
}

extension View {
    func card(padding: CGFloat = 16, radius: CGFloat = Theme.radiusMedium) -> some View {
        modifier(CardModifier(padding: padding, radius: radius))
    }

    /// Applies the app background consistently.
    func studyBackground() -> some View {
        background(Theme.background.ignoresSafeArea())
    }
}

// MARK: - Primary button style

struct PrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color(hex: 0x101014))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                Theme.accent.opacity(enabled ? 1 : 0.4),
                in: RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Theme.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
