import SwiftUI

struct MainMenuView: View {
    @StateObject private var settings = GameSettings()
    @State private var playerName: String = ""
    @State private var path = NavigationPath()
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // Floating background bubbles
                GeometryReader { geometry in
                    ForEach(0..<10) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.05...0.2)))
                            .frame(width: CGFloat.random(in: 20...80))
                            .position(x: CGFloat.random(in: 0...geometry.size.width),
                                      y: isAnimating ? -100 : geometry.size.height + 100)
                            .animation(
                                Animation.linear(duration: Double.random(in: 5...15))
                                    .repeatForever(autoreverses: false)
                                    .delay(Double.random(in: 0...5)),
                                value: isAnimating
                            )
                    }
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Title
                    VStack(spacing: -10) {
                        Text("BUBBLE")
                            .font(.system(size: 60, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .purple, radius: 10, x: 0, y: 0)
                        Text("POP")
                            .font(.system(size: 60, weight: .black, design: .rounded))
                            .foregroundColor(.pink)
                            .shadow(color: .pink.opacity(0.8), radius: 10, x: 0, y: 0)
                    }
                    
                    VStack(spacing: 20) {
                        TextField("Enter Player Name", text: $playerName)
                            .font(.title3)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .multilineTextAlignment(.center)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                        
                        MenuButton(title: "New Game", color: .pink) {
                            if playerName.isEmpty {
                                playerName = "Anonymous"
                            }
                            path.append("GameView")
                        }
                        
                        MenuButton(title: "Settings", color: .purple) {
                            path.append("SettingsView")
                        }
                        
                        MenuButton(title: "Scoreboard", color: .blue) {
                            path.append("ScoreboardView")
                        }
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                isAnimating = true
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "GameView":
                    GameView(playerName: playerName, gameTime: settings.gameTime, maxBubbles: settings.maxBubbles, path: $path)
                case "SettingsView":
                    SettingsView(settings: settings)
                case "ScoreboardView":
                    ScoreboardView(path: $path)
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2.bold())
                .frame(width: 250, height: 60)
                .background(
                    LinearGradient(gradient: Gradient(colors: [color.opacity(0.8), color]), startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(30)
                .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}
