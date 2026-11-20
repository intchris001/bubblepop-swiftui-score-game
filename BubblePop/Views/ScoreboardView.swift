import SwiftUI

struct ScoreboardView: View {
    @StateObject private var viewModel = ScoreboardViewModel()
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Hall of Fame")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 0)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(Array(viewModel.scores.enumerated()), id: \.element.id) { index, score in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .frame(width: 40, alignment: .leading)
                                    .foregroundColor(index < 3 ? .yellow : .white)
                                
                                Text(score.name)
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(score.score)")
                                    .font(.title2.bold())
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.white.opacity(index % 2 == 0 ? 0.1 : 0.05))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(index == 0 ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    path.removeLast(path.count)
                }) {
                    Text("Main Menu")
                        .font(.title2.bold())
                        .frame(width: 250, height: 60)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.8), Color.pink]), startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(color: Color.pink.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
