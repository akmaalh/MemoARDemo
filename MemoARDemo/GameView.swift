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
    // add new color for button: F3C670 and B0410F
    let mainColor = Color(red: 0.95, green: 0.78, blue: 0.44) // Soft Yellow
    let secondaryColor = Color(red: 0.69, green: 0.25, blue: 0.07) // Dark Brown

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
                    GarageARView(
                        scoreUpdateHandler: { newScore in score = newScore },
                        gameSaveHandler: { saveGameRecord(theme: theme) },
                        requestSelectThemeHandler: { selectedTheme = nil },
                        requestShowHistoryHandler: { selectedTheme = nil; showHistory = true },
                        userName: currentUserName,
                        themeDisplayName: currentThemeDisplayName
                    )
                case .bathroom:
                    BathroomARView(
                        scoreUpdateHandler: { newScore in score = newScore },
                        gameSaveHandler: { saveGameRecord(theme: theme) },
                        requestSelectThemeHandler: { selectedTheme = nil },
                        requestShowHistoryHandler: { selectedTheme = nil; showHistory = true },
                        userName: currentUserName,
                        themeDisplayName: currentThemeDisplayName
                    )
                }
            } else if showHistory {
                HistoryView()
            } else {
                // Embed ThemeSelectionView in a ZStack for background color
                ZStack {
                    backgroundColor.edgesIgnoringSafeArea(.all)
                    ThemeSelectionView(selectedTheme: $selectedTheme,
                                       buttonColor: mainColor,
                                       buttonTextColor: secondaryColor,
                                       textColor: textColor,
                                       logoColor: buttonColor) // Pass colors
                }
            }
        }
        .environment(\.locale, Locale(identifier: "id"))
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
    // Colors passed from GameView
    let buttonColor: Color
    let buttonTextColor: Color
    let textColor: Color
    let logoColor: Color
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(logoColor)
                .padding(.top, 20)

            Text("Pilih Tema")
                .font(.custom("verdana-bold", size: 34))
                .foregroundColor(textColor)
                .accessibilityAddTraits(.isHeader)

            GeometryReader { geometry in
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        ThemeCardButton(
                            assetName: "kitchen-icon",
                            title: "Dapur",
                            subtitle: "Tema Dapur",
                            color: buttonColor,
                            action: { selectedTheme = .kitchen },
                            textColor: buttonTextColor,
                            width: (geometry.size.width - 24 - 10) / 2
                        )
                        ThemeCardButton(
                            assetName: "bathroom-icon",
                            title: "Kamar Mandi",
                            subtitle: "Tema Kamar Mandi",
                            color: buttonColor,
                            action: { selectedTheme = .bathroom },
                            textColor: buttonTextColor,
                            width: (geometry.size.width - 24 - 10) / 2
                        )
                    }
                    HStack {
                        Spacer(minLength: 0)
                        ThemeCardButton(
                            assetName: "garage-icon",
                            title: "Garasi",
                            subtitle: "Tema Garasi",
                            color: buttonColor,
                            action: { selectedTheme = .garage },
                            textColor: buttonTextColor,
                            width: (geometry.size.width - 24 - 10) / 2
                        )
                        Spacer(minLength: 0)
                    }
                }
                .frame(width: geometry.size.width)
            }
            .frame(height: 380)
            Spacer()
        }
        .padding(.horizontal, 12)
        .environment(\.locale, Locale(identifier: "id"))
    }
}

struct ThemeCardButton: View {
    let assetName: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    let textColor: Color
    let width: CGFloat

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .padding(.top, 18)
                    .padding(.bottom, 14)
                    .foregroundColor(textColor)
                Text(title)
                    .font(.custom("verdana-bold", size: 18))
                    .foregroundColor(textColor)
            }
            .frame(width: width, height: 150)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: color.opacity(0.18), radius: 8, x: 0, y: 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title), \(subtitle)")
        }
        .buttonStyle(PlainButtonStyle())
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

#Preview {
    GameView(showHistory: false) // Pass the required argument
        .environmentObject(GameDataManager()) // Add environment object for preview
}
