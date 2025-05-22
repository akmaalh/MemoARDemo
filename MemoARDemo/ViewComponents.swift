import SwiftUI

// Common Button Style used across multiple views
struct MainButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.semibold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

// Add other shared view components or helpers here if needed

// Simple Confetti Animation View for SwiftUI
struct ConfettiView: View {
    @Binding var isVisible: Bool
    let colors: [Color]
    let duration: Double
    let particleCount: Int

    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .animation(.easeOut(duration: duration), value: particle.position)
                }
            }
            .allowsHitTesting(false)
            .onChange(of: isVisible) { show in
                if show {
                    generateParticles(in: geometry.size)
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        isVisible = false
                    }
                } else {
                    particles = []
                }
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 8...18),
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -30),
                opacity: 1.0
            )
        }
        // Animate particles falling
        for i in particles.indices {
            let endY = CGFloat.random(in: size.height * 0.5...size.height * 1.1)
            let endX = particles[i].position.x + CGFloat.random(in: -100...100)
            let delay = Double.random(in: 0...0.2)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: duration)) {
                    particles[i].position = CGPoint(x: endX, y: endY)
                    particles[i].opacity = 0.0
                }
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}
