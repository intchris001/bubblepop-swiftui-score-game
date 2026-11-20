import Foundation
import SwiftUI

enum GameState {
    case preGame
    case playing
    case gameOver
}

class GameViewModel: ObservableObject {
    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var gameState: GameState = .preGame
    @Published var preGameCountdown: Int = 3
    @Published var popFeedbacks: [PopFeedback] = []
    @Published var currentCombo: Double = 1.0
    
    private var mainTimer: Timer?
    private var animationTimer: Timer?
    private var totalGameTime: Int
    private var maxAllowedBubbles: Int
    private var previousBubbleColor: BubbleColor?
    private var playableArea: CGRect = .zero
    
    init(gameTime: Int, maxBubbles: Int) {
        self.timeRemaining = gameTime
        self.totalGameTime = gameTime
        self.maxAllowedBubbles = maxBubbles
    }
    
    func startGame(bounds: CGRect) {
        self.playableArea = bounds
        self.score = 0
        self.gameState = .preGame
        self.preGameCountdown = 3
        self.bubbles.removeAll()
        self.popFeedbacks.removeAll()
        self.previousBubbleColor = nil
        self.currentCombo = 1.0
        
        startPreGameCountdown()
    }
    
    private func startPreGameCountdown() {
        mainTimer?.invalidate()
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.preGameCountdown > 1 {
                self.preGameCountdown -= 1
            } else {
                self.mainTimer?.invalidate()
                self.startActualGame()
            }
        }
    }
    
    private func startActualGame() {
        self.gameState = .playing
        spawnNewBubbles()
        
        // 1-second timer for game logic (countdown & refresh)
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.processGameTick()
        }
        
        // 0.03-second timer for smooth movement (approx 30 fps)
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateBubblePositions()
        }
    }
    
    func stopGame() {
        mainTimer?.invalidate()
        animationTimer?.invalidate()
        mainTimer = nil
        animationTimer = nil
        gameState = .gameOver
    }
    
    private func processGameTick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            refreshBoard()
        } else {
            stopGame()
        }
    }
    
    private func updateBubblePositions() {
        guard gameState == .playing else { return }
        
        // Calculate speed multiplier based on remaining time
        // Speeds up to 2.5x as time runs out
        let timeProgress = 1.0 - (Double(timeRemaining) / Double(totalGameTime))
        let speedMultiplier = 1.0 + (timeProgress * 1.5)
        
        for i in (0..<bubbles.count).reversed() {
            bubbles[i].position.x += bubbles[i].dx * CGFloat(speedMultiplier)
            bubbles[i].position.y += bubbles[i].dy * CGFloat(speedMultiplier)
            
            // Remove if completely off screen
            let currentBubble = bubbles[i]
            let radius = currentBubble.size / 2.0
            if currentBubble.position.x < -radius || currentBubble.position.x > playableArea.width + radius ||
               currentBubble.position.y < -radius || currentBubble.position.y > playableArea.height + radius {
                bubbles.remove(at: i)
            }
        }
    }
    
    func popBubble(_ bubble: Bubble) {
        guard gameState == .playing else { return }
        
        if let foundIndex = bubbles.firstIndex(where: { $0.id == bubble.id }) {
            bubbles.remove(at: foundIndex)
            
            // Calculate points and combo
            var comboMultiplier = 1.0
            if let lastColor = previousBubbleColor, lastColor == bubble.type {
                comboMultiplier = 1.5
                currentCombo = 1.5
            } else {
                currentCombo = 1.0
            }
            
            let pointsEarned = Double(bubble.type.points) * comboMultiplier
            let finalPoints = Int(round(pointsEarned))
            score += finalPoints
            previousBubbleColor = bubble.type
            
            // Create visual feedback
            let feedbackString = comboMultiplier > 1.0 ? "+\(finalPoints) (Combo!)" : "+\(finalPoints)"
            let newFeedback = PopFeedback(text: feedbackString, position: bubble.position, color: bubble.type.colors.first ?? .white)
            popFeedbacks.append(newFeedback)
            
            // Remove feedback after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.popFeedbacks.removeAll(where: { $0.id == newFeedback.id })
            }
        }
    }
    
    private func refreshBoard() {
        // Randomly remove some existing bubbles
        let bubblesToRemove = Int.random(in: 0...max(0, bubbles.count))
        for _ in 0..<bubblesToRemove {
            if !bubbles.isEmpty {
                let randomIndex = Int.random(in: 0..<bubbles.count)
                bubbles.remove(at: randomIndex)
            }
        }
        
        spawnNewBubbles()
    }
    
    private func spawnNewBubbles() {
        let activeCount = bubbles.count
        let bubblesToCreate = Int.random(in: 0...(maxAllowedBubbles - activeCount))
        
        for _ in 0..<bubblesToCreate {
            if let newBubble = attemptToPlaceBubble() {
                bubbles.append(newBubble)
            }
        }
    }
    
    private func attemptToPlaceBubble() -> Bubble? {
        let expectedSize: CGFloat = 60.0
        let spacing: CGFloat = 10.0
        let halfSize = expectedSize / 2.0
        
        // Try up to 50 times to find an empty spot
        for _ in 0..<50 {
            let randomX = CGFloat.random(in: halfSize...(playableArea.width - halfSize))
            let randomY = CGFloat.random(in: halfSize...(playableArea.height - halfSize))
            let candidatePoint = CGPoint(x: randomX, y: randomY)
            
            // Check for overlaps with existing bubbles
            var hasOverlap = false
            for existing in bubbles {
                let diffX = existing.position.x - candidatePoint.x
                let diffY = existing.position.y - candidatePoint.y
                let dist = sqrt(diffX * diffX + diffY * diffY)
                if dist < (expectedSize + spacing) {
                    hasOverlap = true
                    break
                }
            }
            
            if !hasOverlap {
                // Generate random drifting velocities
                let velocityX = CGFloat.random(in: -1.5...1.5)
                let velocityY = CGFloat.random(in: -1.5...1.5)
                return Bubble(type: BubbleColor.random(), position: candidatePoint, dx: velocityX, dy: velocityY)
            }
        }
        
        // Return nil if space couldn't be found
        return nil
    }
}
