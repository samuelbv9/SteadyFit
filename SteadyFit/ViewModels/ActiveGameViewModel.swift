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
    
    func fetchCurrentGame(userId: String, gameCode: String) async throws -> [GameData] {
        guard let url = URL(string: "http://52.200.16.208/api/goal/?user_id=\(userId)&game_code=\(gameCode)") else {
            self.errorMessage = "Invalid URL"
            return []
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GameResponse.self, from: data)
        
        return decoded.results
    }

    func loadCurrentGame(userId: String, gameCode: String) {
        Task {
            do {
                let gameData = try await fetchCurrentGame(userId: userId, gameCode: gameCode)
                // print(game)
            } catch {
                print("Error fetching current game: \(error)")
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
