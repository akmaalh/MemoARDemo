//
//  Game.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

// GameRecord.swift
import Foundation

struct GameRecord: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var userName: String
    var score: Int
    
    static func createNew(userName: String, score: Int) -> GameRecord {
        return GameRecord(date: Date(), userName: userName, score: score)
    }
}

// GameDataManager.swift
class GameDataManager: ObservableObject {
    @Published var currentUser: User?
    @Published var gameHistory: [GameRecord] = []
    
    private let userDefaultsKey = "gameUser"
    private let historyDefaultsKey = "gameHistory"
    
    init() {
        loadUser()
        loadHistory()
    }
    
    var hasUser: Bool {
        return currentUser != nil && !(currentUser?.name.isEmpty ?? true)
    }
    
    func saveUser(_ user: User) {
        currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadUser() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }
    
    func saveGameResult(score: Int) {
        guard let userName = currentUser?.name else { return }
        
        // Create new record
        let newRecord = GameRecord.createNew(userName: userName, score: score)
        gameHistory.append(newRecord)
        
        // Update high score if needed
        if score > (currentUser?.highScore ?? 0) {
            var updatedUser = currentUser!
            updatedUser.highScore = score
            saveUser(updatedUser)
        }
        
        // Save history
        saveHistory()
    }
    
    func loadHistory() {
        if let historyData = UserDefaults.standard.data(forKey: historyDefaultsKey),
           let history = try? JSONDecoder().decode([GameRecord].self, from: historyData) {
            gameHistory = history
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(gameHistory) {
            UserDefaults.standard.set(encoded, forKey: historyDefaultsKey)
        }
    }
    
    func clearHistory() {
        gameHistory = []
        saveHistory()
    }
}
