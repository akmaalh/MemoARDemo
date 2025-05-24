import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var dataManager: GameDataManager
    @State private var userName: String = "Nama" // Default name

    // Define colors based on the image
    let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.93) // Light cream
    let mainButtonColor = Color(red: 0.43, green: 0.80, blue: 0.29) // Soft green #6ECD49
    let secondaryButtonColor = Color(red: 0.0, green: 0.48, blue: 1.0) // Soft blue #007AFF
    let tertiaryButtonColor = Color(red: 0.95, green: 0.73, blue: 0.32) // Soft yellow #F1BA52
    let buttonTextColor = Color.black // High contrast for elderly
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark text for greetings
    let buttonColor = Color(red: 0.95, green: 0.69, blue: 0.26) // Orange
    // add hex B0410F and F1BA52 as color
    let secondaryColor = Color(red: 0.69, green: 0.25, blue: 0.07) // Dark Brown
    let mainColor = Color(red: 0.95, green: 0.78, blue: 0.44) // Soft Yellow

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Logo
                    Image(systemName: "brain.head.profile") // Placeholder for MemoAR logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 50)
                        .foregroundColor(buttonColor)
                    
                    Text("MemoAR")
                        .font(.custom("verdana-bold", size: 45))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
 
                    // Greeting
                    Text("Halo, \(userName)!")
                        .font(.custom("verdana-bold", size: 35))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    Text("mainkan memoAR untuk tingkatkan memorimu!")
                        .font(.custom("verdana", size: 20))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)

                    NavigationLink(destination: GameView(showHistory: false).environmentObject(dataManager)) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 30))
                            Text("Mulai Latihan")
                        }
                        .modifier(MainButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, fontSize: 24, isBold: true))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(secondaryColor.opacity(0.6), lineWidth: 3)
                        )
                        .accessibilityLabel("Mulai Permainan")
                    }

                    NavigationLink(destination: GameView(showHistory: true).environmentObject(dataManager)) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 24))
                            Text("Histori Poin")
                        }
                        .modifier(MainButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, fontSize: 24, isBold: true))
                        .accessibilityLabel("Histori Poin")
                    }

                    NavigationLink(destination: TutorialView().environmentObject(dataManager)) {
                        HStack {
                            Image(systemName: "video.fill")
                                .font(.system(size: 24))
                            Text("Cara Bermain")
                        }
                        .modifier(MainButtonModifier(backgroundColor: secondaryColor, textColor: mainColor, fontSize: 22, isBold: false))
                        .accessibilityLabel("Lihat Video Tutorial")
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true) // Hide navigation bar for a cleaner look
            .onAppear {
                if let currentUser = dataManager.currentUser {
                    userName = currentUser.name
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Recommended for fixing potential console warnings
    }
}

// Button Style Modifier
struct MainButtonModifier: ViewModifier {
    let backgroundColor: Color
    let textColor: Color
    var fontSize: CGFloat = 25
    var isBold: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.custom(isBold ? "verdana-bold" : "verdana", fixedSize: fontSize))
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environmentObject(GameDataManager()) // Ensure preview has the environment object
    }
} 
