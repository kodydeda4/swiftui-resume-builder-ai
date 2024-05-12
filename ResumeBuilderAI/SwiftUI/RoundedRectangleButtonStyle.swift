import SwiftUI

struct RoundedRectangleButtonStyle: ButtonStyle {
  var foregroundColor = Color.white
  var backgroundColor = Color.accentColor
  var strokeColor: Color?
  var radius = CGFloat(8)
  var inFlight = false
  var hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle?

  func makeBody(configuration: Self.Configuration) -> some View {
    Group {
      if inFlight {
        ProgressView()
          .tint(.white)
      } else {
        configuration.label
      }
    }
    .font(.body)
    .fontWeight(.semibold)
    .foregroundColor(foregroundColor)
    .frame(height: 16*3)
    .frame(maxWidth: .infinity)
    .background {
      backgroundColor.overlay {
        Color.black.opacity(configuration.isPressed ? 0.25 : 0)
      }
    }
    .clipShape(RoundedRectangle(
      cornerRadius: radius,
      style: .continuous
    ))
    .overlay {
      if let strokeColor {
        RoundedRectangle(
          cornerRadius: radius,
          style: .continuous
        )
        .strokeBorder(lineWidth: 2)
        .foregroundColor(strokeColor)
      }
    }
    .animation(.default, value: configuration.isPressed)
    .onChange(of: configuration.isPressed) {
      if let hapticFeedback, configuration.isPressed {
        UIImpactFeedbackGenerator(style: hapticFeedback)
          .impactOccurred()
      }
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  Button("Click Me") {
    //...
  }
  .buttonStyle(RoundedRectangleButtonStyle(
    inFlight: true
  ))
  .padding()
}
