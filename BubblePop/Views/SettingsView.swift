import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: GameSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Settings")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.pink)
                            Text("Game Time: \(settings.gameTime) seconds")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Slider(value: Binding(
                            get: { Double(settings.gameTime) },
                            set: { settings.gameTime = Int($0) }
                        ), in: 10...120, step: 1)
                        .accentColor(.pink)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "circle.grid.hex.fill")
                                .foregroundColor(.blue)
                            Text("Maximum Bubbles: \(settings.maxBubbles)")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Slider(value: Binding(
                            get: { Double(settings.maxBubbles) },
                            set: { settings.maxBubbles = Int($0) }
                        ), in: 5...30, step: 1)
                        .accentColor(.blue)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
