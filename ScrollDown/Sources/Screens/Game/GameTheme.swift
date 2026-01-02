import SwiftUI
import UIKit

enum GameTheme {
    static let accentColor = Color.blue
    static let background = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.secondarySystemBackground
            : UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1) // #F7F8FA
    })
    static let cardBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.secondarySystemBackground
            : .white // #FFFFFF
    })
    static let cardBorder = Color(.systemGray5)
    static let cardShadow = Color.black.opacity(0.06)
    static let cardShadowRadius: CGFloat = 6
    static let cardShadowYOffset: CGFloat = 2
}
