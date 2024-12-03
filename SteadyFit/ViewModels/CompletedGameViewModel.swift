//
//  CompletedGameViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 12/3/24.
//

import FirebaseAuth
import Foundation
import Combine

class CompletedGameViewModel: ObservableObject {
    @Published var gameData: GameDataCompleted?
    func fetchGameData(gameCode: String) async throws -> GameDataCompleted {
        guard let url = URL(string: "https://52.200.16.208/game_details/?game_code=\(gameCode)") else {
            return GameDataCompleted(gameData: GameDataCompleted.GameData(gamecode: "failed", betamount: "0", exercisetype: "failed", frequency: "0", distance: "0", duration: 0, adaptivegoals: false, startdate: "failed", lastupdated: 0, isactive: false), participantsData: [])
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
        let decoded = try JSONDecoder().decode(GameDataCompleted.self, from: data)
        
        return decoded
    }
    
    func loadPastGame(gameCode: String) {
        Task {
            do {
                let gameData = try await fetchGameData(gameCode: gameCode)
                self.gameData = gameData
            } catch {
                print("Error fetching current game: \(error)")
            }
        }
    }

    func getCurrentUserParticipantData() -> GameDataCompleted.ParticipantData? {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user found.")
            return nil
        }
        
        return gameData?.participantsData.first { $0.userId == userId }
    }
}

struct GameDataCompleted: Decodable {
    struct GameData: Decodable {
        let gamecode: String
        let betamount: String
        let exercisetype: String
        let frequency: String?
        let distance: String?
        let duration: Int
        let adaptivegoals: Bool
        let startdate: String
        let lastupdated: Int
        let isactive: Bool
    }
    
    struct ParticipantData: Decodable {
        let gameCode: String
        let userId: String
        let email: String
        let amountGained: String
        let amountLost: String
        let balance: String
        let totalDistance: String?
        let weekDistance: String?
        let weekDistanceGoal: String?
        let totalFrequency: Int?
        let weekFrequency: Int?
        let weekFrequencyGoal: Int?
    }
    
    let gameData: GameData
    let participantsData: [ParticipantData]
}
