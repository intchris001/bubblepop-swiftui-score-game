import Foundation
import SwiftUI

// Represents the different types of bubbles available in the game.
// Contains their respective points, colors, and appearance probabilities.
enum BubbleColor: CaseIterable {
    case red, pink, green, blue, black
    
    // Gets the base points for a specific bubble color
    var points: Int {
        switch self {
        case .red: return 1
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10
        }
    }
    
    // Returns gradient colors for drawing the bubble
    var colors: [Color] {
        switch self {
        case .red: return [Color(red: 1.0, green: 0.3, blue: 0.3), Color(red: 0.8, green: 0.0, blue: 0.0)]
        case .pink: return [Color(red: 1.0, green: 0.5, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.5)]
        case .green: return [Color(red: 0.4, green: 0.9, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.1)]
        case .blue: return [Color(red: 0.3, green: 0.7, blue: 1.0), Color(red: 0.0, green: 0.4, blue: 0.9)]
        case .black: return [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.1, green: 0.1, blue: 0.1)]
        }
    }
    
    // Picks a random bubble type based on the assignment probability table
    static func random() -> BubbleColor {
        let chance = Double.random(in: 0...100)
        
        if chance < 40 {
            return .red // 40% probability
        } else if chance < 70 {
            return .pink // 30% probability
        } else if chance < 85 {
            return .green // 15% probability
        } else if chance < 95 {
            return .blue // 10% probability
        } else {
            return .black // 5% probability
        }
    }
}

// Model for an individual bubble entity on the screen
struct Bubble: Identifiable, Equatable {
    let id = UUID()
    let type: BubbleColor
    var position: CGPoint
    var dx: CGFloat // Velocity in the X axis
    var dy: CGFloat // Velocity in the Y axis
    let size: CGFloat = 60.0 // Standard size for all bubbles
    
    static func == (lhs: Bubble, rhs: Bubble) -> Bool {
        return lhs.id == rhs.id
    }
}

// Stores info for floating text animations after popping
struct PopFeedback: Identifiable {
    let id = UUID()
    let text: String
    let position: CGPoint
    let color: Color
}
