import SwiftUI

struct GameView: View {
    let playerName: String
    let gameTime: Int
    let maxBubbles: Int
    @Binding var path: NavigationPath
    
    @StateObject private var viewModel: GameViewModel
    @StateObject private var scoreboard = ScoreboardViewModel()
    
    init(playerName: String, gameTime: Int, maxBubbles: Int, path: Binding<NavigationPath>) {
        self.playerName = playerName
        self.gameTime = gameTime
        self.maxBubbles = maxBubbles
        self._path = path
        _viewModel = StateObject(wrappedValue: GameViewModel(gameTime: gameTime, maxBubbles: maxBubbles))
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top HUD
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "timer")
                            Text("\(viewModel.timeRemaining)s")
                        }
                        .font(.title2.bold())
                        .foregroundColor(viewModel.timeRemaining <= 10 ? .red : .white)
                        
                        HStack {
                            Image(systemName: "star.circle.fill")
                            Text("Score: \(viewModel.score)")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("High Score")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(scoreboard.scores.first?.score ?? 0)")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                .padding(.horizontal)
                
                GeometryReader { geometry in
                    ZStack {
                        Color.clear // Interaction area
                        
                        // Bubbles
                        ForEach(viewModel.bubbles) { bubble in
                            BubbleView(bubble: bubble) {
                                // Haptic feedback
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                                    viewModel.popBubble(bubble)
                                }
                            }
                        }
                        
                        // Floating score texts
                        ForEach(viewModel.popFeedbacks) { feedback in
                            FloatingFeedbackView(feedback: feedback)
                        }
                    }
                    .onAppear {
                        viewModel.startGame(bounds: geometry.frame(in: .local))
                    }
                    .onChange(of: viewModel.gameState) { state in
                        if state == .gameOver {
                            scoreboard.saveScore(name: playerName, score: viewModel.score)
                            path.append("ScoreboardView")
                        }
                    }
                }
            }
            
            // Pre-game Countdown Overlay
            if viewModel.gameState == .preGame {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                Text("\(viewModel.preGameCountdown)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
                    .id(viewModel.preGameCountdown) // Forces transition on change
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.stopGame()
                    path.removeLast()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Quit")
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// Subview for Bubble rendering
struct BubbleView: View {
    let bubble: Bubble
    let onTap: () -> Void
    @State private var scale: CGFloat = 0.1
    
    var body: some View {
        Circle()
            .fill(LinearGradient(gradient: Gradient(colors: bubble.type.colors), startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: bubble.size, height: bubble.size)
            // Glossy inner shadow effect
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .blur(radius: 2)
                    .offset(x: -2, y: -2)
                    .mask(Circle())
            )
            .shadow(color: bubble.type.colors.first!.opacity(0.6), radius: 8, x: 0, y: 5)
            .scaleEffect(scale)
            .position(bubble.position)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            .onTapGesture {
                onTap()
            }
    }
}

// Subview for Floating Points
struct FloatingFeedbackView: View {
    let feedback: PopFeedback
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Text(feedback.text)
            .font(.headline.bold())
            .foregroundColor(feedback.color)
            .shadow(color: .black, radius: 2, x: 1, y: 1)
            .position(x: feedback.position.x, y: feedback.position.y - offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offset = 60
                    opacity = 0
                }
            }
    }
}
