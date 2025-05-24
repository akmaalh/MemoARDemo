import SwiftUI

// Define the confetti piece structure
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var color: Color
    var initialPosition: CGPoint // Initial position within the GeometryReader bounds
    var initialAngle: Angle
    var initialScale: CGFloat = 1.0

    static func randomColor() -> Color {
        return [Color.red, Color.blue, Color.green, Color.yellow, Color.pink, Color.orange, Color.purple].randomElement()!
    }
    // Generates a random position starting from above the screen to near the top edge
    static func randomInitialPosition(in rect: CGRect) -> CGPoint {
        return CGPoint(x: CGFloat.random(in: rect.minX...rect.maxX), y: CGFloat.random(in: rect.minY - 60 ... rect.minY - 10))
    }
    static func randomAngle() -> Angle {
        return .degrees(Double.random(in: -270...270))
    }
}

struct GameOverSwiftUIView: View {
    @Environment(\.presentationMode) var presentationMode

    let themeTitle: String
    let userName: String
    let score: Int
    let isNewHighScore: Bool // New parameter

    let onTryAgain: () -> Void
    let onSelectTheme: () -> Void
    let onShowHistory: () -> Void

    // Consistent colors
    let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.93) // Light cream
    let mainColor = Color(red: 0.95, green: 0.78, blue: 0.44) // Soft Yellow
    let secondaryColor = Color(red: 0.69, green: 0.25, blue: 0.07) // Dark Brown
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark text
    let highlightColor = Color.orange // For new high score elements

    // State for confetti
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var animateConfettiContent = false // To control the animation trigger for confetti and score pulse

    private func generateConfetti(screenSize: CGSize) {
        guard confettiPieces.isEmpty else { return } // Generate only once
        for _ in 0..<120 { // Increased confetti count
            let piece = ConfettiPiece(
                color: ConfettiPiece.randomColor(),
                initialPosition: ConfettiPiece.randomInitialPosition(in: CGRect(origin: .zero, size: screenSize)),
                initialAngle: ConfettiPiece.randomAngle(),
                initialScale: CGFloat.random(in: 0.4...1.0) // Slightly smaller max scale
            )
            confettiPieces.append(piece)
        }
    }
    
    private func motivationalMessage() -> String {
        if isNewHighScore {
            return "Selamat \(userName)! Kamu berhasil meraih poin tertinggi!"
        } else {
            return "Kerja bagus, \(userName)!\nPoinmu kali ini:\n"
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)

                // Confetti Layer
                // Only create ConfettiViews if we intend to show them
                if animateConfettiContent && isNewHighScore {
                    ForEach(confettiPieces) { piece in
                        ConfettiParticleView(piece: piece, screenSize: geo.size)
                    }
                }

                VStack(spacing: 20) {
                    Text(themeTitle)
                        .font(.custom("verdana-bold", size: 32))
                        .foregroundColor(textColor)
                        .padding(.top, 40)

                    Spacer()
                    
                    VStack(spacing: 15) {
                        if isNewHighScore {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 36))
                                .foregroundColor(highlightColor)
                                .scaleEffect(animateConfettiContent ? 1.0 : 0.0) // Animate trophy appearance
                                .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.2), value: animateConfettiContent)
                        }
                        
                        Text(motivationalMessage())
                            .font(.custom("verdana", size: 20))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .opacity(animateConfettiContent ? 1 : 0) // Fade in text
                            .animation(.easeIn(duration: 0.5).delay(0.1), value: animateConfettiContent)


                        if isNewHighScore {
                             Text("\(score)")
                                .font(.custom("verdana-bold", size: 60))
                                .foregroundColor(highlightColor)
                                .scaleEffect(animateConfettiContent ? 1.15 : 1.0) // Pulse effect
                                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.5), value: animateConfettiContent)
                        } else {
                            Text("\(score)")
                                .font(.custom("verdana-bold", size: 48))
                                .foregroundColor(textColor)
                        }
                        
                        Text("Terus bermain untuk tingkatkan poin kamu!")
                            .font(.custom("verdana", size: 20))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)

                    Spacer()

                    // Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            onTryAgain()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Coba Lagi")
                                    .font(.custom("verdana-bold", size: 20))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .modifier(GameOverButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, flexibleWidth: true))
                        .accessibilityLabel("Coba Lagi")

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            onSelectTheme()
                        }) {
                            HStack {
                                Image(systemName: "paintpalette")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Pilih Tema")
                                    .font(.custom("verdana-bold", size: 20))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .modifier(GameOverButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, flexibleWidth: true))
                        .accessibilityLabel("Pilih Tema")

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            onShowHistory()
                        }) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Histori Poin")
                                    .font(.custom("verdana-bold", size: 20))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .modifier(GameOverButtonModifier(backgroundColor: mainColor, textColor: secondaryColor, flexibleWidth: false))
                        .accessibilityLabel("Histori Poin")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    Spacer()
                    Spacer()
                }
                .padding()
                .onAppear {
                    if isNewHighScore {
                        generateConfetti(screenSize: geo.size)
                    }
                    // Trigger content animations slightly after view appears for smoother effect
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                           animateConfettiContent = true
                        }
                    }
                }
            }
        }
        // .navigationBarHidden(true) 
    }
}

// Individual Confetti Particle View
struct ConfettiParticleView: View {
    @State var piece: ConfettiPiece // Make it a @State if its properties are changed by the animation directly
    let screenSize: CGSize
    
    @State private var yPos: CGFloat
    @State private var xPos: CGFloat
    @State private var opacity: Double = 1.0
    @State private var rotation: Angle = .degrees(0)
    @State private var scale: CGFloat

    init(piece: ConfettiPiece, screenSize: CGSize) {
        self.piece = piece
        self.screenSize = screenSize
        // Initialize state from the piece's initial properties
        _xPos = State(initialValue: piece.initialPosition.x)
        _yPos = State(initialValue: piece.initialPosition.y)
        _scale = State(initialValue: piece.initialScale)
        _rotation = State(initialValue: piece.initialAngle) // Start with initial random rotation
    }

    var body: some View {
        Capsule()
            .fill(piece.color)
            .frame(width: 10 * piece.initialScale, height: 20 * piece.initialScale) // Use initialScale for base size
            .scaleEffect(scale) // Animated scale
            .rotationEffect(rotation) // Animated rotation
            .position(x: xPos, y: yPos) // Use .position for direct placement
            .opacity(opacity)
            .onAppear {
                let fallDuration = Double.random(in: 2.8...5.0)
                let swayAmount = CGFloat.random(in: -screenSize.width * 0.2...screenSize.width * 0.2)
                let finalRotation = piece.initialAngle + Angle.degrees(Double.random(in: -720...720))
                let animationDelay = Double.random(in: 0...0.5) // Random delay for staggered fall

                withAnimation(.easeOut(duration: fallDuration).delay(animationDelay)) {
                    yPos = screenSize.height + 100 // Fall below the screen
                    xPos += swayAmount
                    opacity = 0
                }
                withAnimation(.linear(duration: fallDuration).delay(animationDelay)) {
                     rotation = finalRotation
                }
                // Optional: animate scale slightly during fall
                withAnimation(.easeInOut(duration: fallDuration * 0.5).delay(animationDelay)) {
                    scale *= CGFloat.random(in: 0.7...1.3) // Slight size variance during fall
                }
                withAnimation(.easeOut(duration: fallDuration * 0.4).delay(fallDuration * 0.6 + animationDelay)) {
                    scale = 0.1 // Shrink significantly at the end
                }
            }
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
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
    }
}

struct GameOverSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for new high score
        GameOverSwiftUIView(
            themeTitle: "Dapur",
            userName: "Juara",
            score: 100,
            isNewHighScore: true, // Test with new high score
            onTryAgain: { print("Try Again Tapped") },
            onSelectTheme: { print("Select Theme Tapped") },
            onShowHistory: { print("Show History Tapped") }
        )
        .previewDisplayName("New High Score")

        // Preview for regular game over
        GameOverSwiftUIView(
            themeTitle: "Kantor",
            userName: "Pekerja Keras",
            score: 50,
            isNewHighScore: false, // Test without new high score
            onTryAgain: { print("Try Again Tapped") },
            onSelectTheme: { print("Select Theme Tapped") },
            onShowHistory: { print("Show History Tapped") }
        )
        .previewDisplayName("Regular Game Over")
    }
} 
