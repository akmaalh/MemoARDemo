import SwiftUI

struct GameOverSwiftUIView: View {
    @Environment(\.presentationMode) var presentationMode

    let themeTitle: String
    let userName: String
    let score: Int

    let onTryAgain: () -> Void
    let onSelectTheme: () -> Void
    let onShowHistory: () -> Void

    // Consistent colors
    let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.93) // Light cream
    let buttonColor = Color(red: 0.95, green: 0.69, blue: 0.26)     // Orange
    let buttonTextColor = Color(red: 0.4, green: 0.2, blue: 0.1)    // Dark Brown
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2)          // Dark text

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 25) { // Adjusted spacing
                Text(themeTitle)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.top, 60)

                Spacer()

                Text("Halo \(userName)!")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(textColor)

                Text("Poin kamu:")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(textColor)
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.bottom, 30)
                
                Spacer()

                // Buttons
                HStack(spacing: 15) {
                    Button("Coba Lagi") {
                        presentationMode.wrappedValue.dismiss()
                        onTryAgain()
                    }
                    .modifier(GameOverButtonModifier(backgroundColor: buttonColor, textColor: buttonTextColor, flexibleWidth: true))

                    Button("Pilih Tema") {
                        presentationMode.wrappedValue.dismiss()
                        onSelectTheme()
                    }
                    .modifier(GameOverButtonModifier(backgroundColor: buttonColor, textColor: buttonTextColor, flexibleWidth: true))
                }
                .padding(.horizontal, 20)

                Button("Histori Nilai") {
                    presentationMode.wrappedValue.dismiss()
                    onShowHistory()
                }
                .modifier(GameOverButtonModifier(backgroundColor: buttonColor, textColor: buttonTextColor, flexibleWidth: false))
                .padding(.horizontal, 20) // Match horizontal padding for the single button
                .padding(.top, 10) // Add some space above the single button

                Spacer()
                Spacer()
            }
            .padding()
        }
        // It's better to control navigation bar visibility from the presenting UIViewController
        // .navigationBarHidden(true) 
    }
}

struct GameOverButtonModifier: ViewModifier {
    let backgroundColor: Color
    let textColor: Color
    let flexibleWidth: Bool

    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(maxWidth: flexibleWidth ? .infinity : nil)
            .frame(height: 55) // Adjusted height
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
    }
}

struct GameOverSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverSwiftUIView(
            themeTitle: "Dapur",
            userName: "Nama",
            score: 8,
            onTryAgain: { print("Try Again Tapped") },
            onSelectTheme: { print("Select Theme Tapped") },
            onShowHistory: { print("Show History Tapped") }
        )
    }
} 