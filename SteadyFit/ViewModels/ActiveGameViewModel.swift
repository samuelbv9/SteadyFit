//
//  ActiveGameViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 11/3/24.
//

import FirebaseAuth
import Foundation
import Combine

class ActiveGameViewModel: ObservableObject {
    @Published var gameData: GameData?
    @Published var errorMessage: String?
    
    func fetchCurrentGame(userId: String, gameCode: String) async throws -> GameData {
        // http://52.200.16.208/goal/?game_code=NODqAbjW&user_id=8503f31c-8c1f-45eb-a7dd-180095aad816
        guard let url = URL(string: "https://52.200.16.208/api/goal/?user_id=\(userId)&game_code=\(gameCode)") else {
            self.errorMessage = "Invalid URL"
            return GameData(exerciseType: "failed", currentDistance: 0, currentFrequency: 0, totalDistance: 0, totalFrequency: 0)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GameResponse.self, from: data)
        
        return decoded.results.first!
    }

    func loadCurrentGame(userId: String, gameCode: String) {
        Task {
            do {
                let gameData = try await fetchCurrentGame(userId: userId, gameCode: gameCode)
                self.gameData = gameData
            } catch {
                print("Error fetching current game: \(error)")
                self.errorMessage = "Error fetching current game: \(error.localizedDescription)"
            }
        }
    }
}

struct GameResponse: Decodable {
    let results: [GameData]
}

struct GameData: Decodable {
    let exerciseType: String
    let currentDistance: Double // Can be null (if distance based, wont be null)
    let currentFrequency: Double // Can be null
    let totalDistance: Double // Can be null
    let totalFrequency: Double // Can be null
}

struct SleepDataPoint: Identifiable {
    var id = UUID().uuidString
    var day: String
    var hours: Int
}
