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
    // Add a isLoading bool for no user visable data updating
    
    func fetchCurrentGame(userId: String, gameCode: String) async throws -> GameData {
        // http://52.200.16.208/goal/?game_code=NODqAbjW&user_id=8503f31c-8c1f-45eb-a7dd-180095aad816
        guard let url = URL(string: "https://52.200.16.208/goal/?user_id=\(userId)&game_code=\(gameCode)") else {
            self.errorMessage = "Invalid URL"
            return GameData(exerciseType: "failed", currentDistance: "0", currentFrequency: 0, totalDistance: "0", totalFrequency: 0)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Print the raw response data for debugging
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        if let responseDataString = String(data: data, encoding: .utf8) {
            print("Response Data: \(responseDataString)")
        }
        
        // Decode directly into GameData
        let decoded = try JSONDecoder().decode(GameData.self, from: data)
        
        return decoded
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

struct GameData: Decodable {
    let exerciseType: String
    let currentDistance: String // Can be null (if distance based, wont be null)
    let currentFrequency: Int // Can be null
    let totalDistance: String // Can be null
    let totalFrequency: Int // Can be null
}

struct SleepDataPoint: Identifiable {
    var id = UUID().uuidString
    var day: String
    var hours: Double
}
