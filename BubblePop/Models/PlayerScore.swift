import Foundation

struct PlayerScore: Identifiable, Codable, Comparable {
    var id = UUID()
    let name: String
    let score: Int
    let date: Date
    
    static func < (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        return lhs.score < rhs.score
    }
}
