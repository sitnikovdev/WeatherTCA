import SwiftUI

public enum DesignTokens {
    public enum Colors {
        public static let primary    = Color.blue
        // Используем адаптивные SwiftUI-цвета через UIColor напрямую.
        // Color(.systemBackground) может триггерить CUICatalog lookup в dynamic framework
        // если Tuist сгенерировал пустой Resources bundle — краш при старте.
        public static let background = Color(UIColor.systemBackground)
        public static let secondary  = Color(UIColor.secondarySystemBackground)
        public static let error      = Color.red
    }
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
    }
    public enum Typography {
        public static let title   = Font.system(.title,   design: .rounded, weight: .bold)
        public static let body    = Font.system(.body,    design: .default)
        public static let caption = Font.system(.caption, design: .monospaced)
    }
}
