import SwiftUI

struct RedeyeLogo: View {
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.90, green: 0.12, blue: 0.12),
                            Color(red: 0.50, green: 0.0, blue: 0.0),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.25), radius: size * 0.12, x: 0, y: size * 0.05)

            Image(systemName: "eye.fill")
                .font(.system(size: size * 0.38, weight: .medium))
                .foregroundStyle(.white.opacity(0.92))
        }
    }
}
