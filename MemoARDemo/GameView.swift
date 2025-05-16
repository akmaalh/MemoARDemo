import SwiftUI
import Foundation
struct GameView: View {
    @EnvironmentObject var dataManager: GameDataManager
    @State private var selectedTheme: GameTheme?
    @State private var score: Int = 0
    @State private var showGameOver = false
    @State var showHistory: Bool

    // Define colors based on the image (consistent with HomeScreen)
    let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.93) // Light cream
    let buttonColor = Color(red: 0.95, green: 0.69, blue: 0.26) // Orange
    let buttonTextColor = Color(red: 0.4, green: 0.2, blue: 0.1) // Dark Brown
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark text

    enum GameTheme {
        case kitchen
        case garage
        case bathroom
        
        var title: String { // English title, might be used internally
            switch self {
            case .kitchen: return "Kitchen"
            case .garage: return "Garage"
            case .bathroom: return "Bathroom"
            }
        }

        // Indonesian display name for UI
        var themeDisplayNameIndonesian: String {
            switch self {
            case .kitchen: return "Dapur"
            case .garage: return "Garasi"
            case .bathroom: return "Kamar Mandi"
            }
        }
    }
    
    var body: some View {
        ZStack {
            if let theme = selectedTheme {
                let currentUserName = dataManager.currentUser?.name ?? "Pemain"
                let currentThemeDisplayName = theme.themeDisplayNameIndonesian

                switch theme {
                case .kitchen:
                    KitchenARView(
                        scoreUpdateHandler: { newScore in score = newScore },
                        gameSaveHandler: { saveGameRecord(theme: theme) },
                        requestSelectThemeHandler: { selectedTheme = nil },
                        requestShowHistoryHandler: { selectedTheme = nil; showHistory = true },
                        userName: currentUserName,
                        themeDisplayName: currentThemeDisplayName
                    )
                case .garage:
                    TutorialView()
                case .bathroom:
                    TutorialView()
                }
            } else if showHistory {
                HistoryView()
            } else {
                // Embed ThemeSelectionView in a ZStack for background color
                ZStack {
                    backgroundColor.edgesIgnoringSafeArea(.all)
                    ThemeSelectionView(selectedTheme: $selectedTheme, 
                                       buttonColor: buttonColor, 
                                       buttonTextColor: buttonTextColor,
                                       textColor: textColor,
                                       logoColor: buttonColor) // Pass colors
                }
            }
        }
    }
    
    private func saveGameRecord(theme: GameTheme) {
        if let user = dataManager.currentUser {
            let record = GameRecord(
                id: UUID(),
                date: Date(),
                userName: user.name,
                score: score,
                theme: theme.title
            )
            dataManager.gameHistory.append(record)
            dataManager.saveHistory()
            
            // Update high score if needed
            if score > user.highScore {
                var updatedUser = user
                updatedUser.highScore = score
                dataManager.saveUser(updatedUser)
            }
        }
    }
}

struct ThemeSelectionView: View {
    @Binding var selectedTheme: GameView.GameTheme?
    // @EnvironmentObject var dataManager: GameDataManager // No longer directly needed for UI
    // @Binding var showHistory: Bool // No longer needed, history accessed from HomeScreen

    // Colors passed from GameView
    let buttonColor: Color
    let buttonTextColor: Color
    let textColor: Color
    let logoColor: Color
    
    var body: some View {
        VStack(spacing: 30) { // Increased spacing
            // Logo
            Image(systemName: "brain.head.profile") // Placeholder for MemoAR logo
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60) // Smaller logo for this screen
                .foregroundColor(logoColor)
                .padding(.top, 20) // Add some padding from the navigation bar

            Text("Pilih Tema")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            
            Button("Dapur") {
                selectedTheme = .kitchen
            }
            .buttonStyle(UpdatedThemeButtonStyle(backgroundColor: buttonColor, textColor: buttonTextColor))
            
            Button("Kamar Mandi") {
                selectedTheme = .bathroom
            }
            .buttonStyle(UpdatedThemeButtonStyle(backgroundColor: buttonColor, textColor: buttonTextColor))
            
            Button("Garasi") {
                selectedTheme = .garage
            }
            .buttonStyle(UpdatedThemeButtonStyle(backgroundColor: buttonColor, textColor: buttonTextColor))
            
            Spacer() // Pushes content to the top
        }
        .padding(.horizontal, 40) // Add horizontal padding
        // .navigationTitle("Pilih Tema") // Set navigation title
        // .navigationBarTitleDisplayMode(.inline) // Optional: if you want smaller title
    }
}

// Renamed and updated ButtonStyle
struct UpdatedThemeButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let textColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2) // Kept font size, can be adjusted
            .fontWeight(.semibold)
            .foregroundColor(textColor) // Use passed text color
            .frame(maxWidth: .infinity) // Make buttons full width within padding
            .frame(height: 60)
            .background(backgroundColor) // Use passed background color
            .cornerRadius(12) // Rounded corners like HomeScreen
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

//#Preview {
//    GameView(showHistory: false) // Pass the required argument
//        .environmentObject(GameDataManager()) // Add environment object for preview
//} 
