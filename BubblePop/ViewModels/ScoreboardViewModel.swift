import Foundation

class ScoreboardViewModel: ObservableObject {
    @Published var scores: [PlayerScore] = []
    
    init() {
        loadScores()
    }
    
    func loadScores() {
        if let data = UserDefaults.standard.data(forKey: "highScores"),
           let decoded = try? JSONDecoder().decode([PlayerScore].self, from: data) {
            scores = decoded.sorted(by: { $0.score > $1.score })
        }
    }
    
    func saveScore(name: String, score: Int) {
        let newScore = PlayerScore(name: name, score: score, date: Date())
        scores.append(newScore)
        scores.sort(by: { $0.score > $1.score })
        
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: "highScores")
        }
    }
}
