import Foundation

class GameSettings: ObservableObject {
    @Published var gameTime: Int {
        didSet {
            UserDefaults.standard.set(gameTime, forKey: "gameTime")
        }
    }
    
    @Published var maxBubbles: Int {
        didSet {
            UserDefaults.standard.set(maxBubbles, forKey: "maxBubbles")
        }
    }
    
    init() {
        let time = UserDefaults.standard.integer(forKey: "gameTime")
        self.gameTime = time > 0 ? time : 60
        
        let bubbles = UserDefaults.standard.integer(forKey: "maxBubbles")
        self.maxBubbles = bubbles > 0 ? bubbles : 15
    }
}
