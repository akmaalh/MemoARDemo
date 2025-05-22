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
    let mainColor = Color(red: 0.95, green: 0.78, blue: 0.44) // Soft Yellow
    let secondaryColor = Color(red: 0.69, green: 0.25, blue: 0.07) // Dark Brown
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark text

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 25) {
                Text(themeTitle)
                    .font(.custom("verdana-bold", size: 36))
                    .foregroundColor(textColor)
                    .padding(.top, 60)

                Spacer()

                Text("Halo \(userName)!")
                    .font(.custom("verdana", size: 24))
                    .foregroundColor(textColor)

                Text("Poin kamu:")
                    .font(.custom("verdana", size: 22))
                    .foregroundColor(textColor)
                Text("\(score)")
                    .font(.custom("verdana-bold", size: 48))
                    .foregroundColor(textColor)
                    .padding(.bottom, 30)
                
                Spacer()

                // Buttons
                HStack(spacing: 15) {
                    Button("Coba Lagi") {
                        presentationMode.wrappedValue.dismiss()
                        onTryAgain()
                    }
                    .modifier(GameOverButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, flexibleWidth: true))

                    Button("Pilih Tema") {
                        presentationMode.wrappedValue.dismiss()
                        onSelectTheme()
                    }
                    .modifier(GameOverButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, flexibleWidth: true))
                }
                .padding(.horizontal, 20)

                Button("Histori Nilai") {
                    presentationMode.wrappedValue.dismiss()
                    onShowHistory()
                }
                .modifier(GameOverButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, flexibleWidth: false))
                .padding(.horizontal, 20)
                .padding(.top, 10)

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
            .font(.custom("verdana-bold", size: 18))
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(maxWidth: flexibleWidth ? .infinity : nil)
            .frame(height: 55)
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