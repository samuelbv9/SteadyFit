//
//  GoalStatusModel.swift
//  SteadyFit
//
//  Created by Hunter Ross on 11/6/24.
//
import Foundation
import Combine

let ENDPOINT: String = "https://52.200.16.208"

// MARK: - Goal Status Model
struct GoalStatus: Codable {
    let totalExpectedDistance: Double
    let totalCompletedDistance: Double
    let totalExpectedFrequency: Int
    let totalCompletedFrequency: Int
    let weeklyExpectedDistance: Double
    let weeklyCompletedDistance: Double
    let weeklyExpectedFrequency: Int
    let weeklyCompletedFrequency: Int
    
    // This is neccessary because a lot of the return values that are supposed to be floats are actually strings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode strings to Double
        totalExpectedDistance = Double(try container.decode(String.self, forKey: .totalExpectedDistance)) ?? 0.0
        totalCompletedDistance = Double(try container.decode(String.self, forKey: .totalCompletedDistance)) ?? 0.0
        weeklyExpectedDistance = Double(try container.decode(String.self, forKey: .weeklyExpectedDistance)) ?? 0.0
        weeklyCompletedDistance = Double(try container.decode(String.self, forKey: .weeklyCompletedDistance)) ?? 0.0
        
        // Decode integers directly
        totalExpectedFrequency = try container.decode(Int.self, forKey: .totalExpectedFrequency)
        totalCompletedFrequency = try container.decode(Int.self, forKey: .totalCompletedFrequency)
        weeklyExpectedFrequency = try container.decode(Int.self, forKey: .weeklyExpectedFrequency)
        weeklyCompletedFrequency = try container.decode(Int.self, forKey: .weeklyCompletedFrequency)
    }
}

// MARK: - Goal Status Service
class GoalStatusService {
    
    func fetchGoalStatus(userId: String, gameCode: String) async throws -> GoalStatus {
        var urlComponents = URLComponents(string: "\(ENDPOINT)/goal_status/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "game_code", value: gameCode)
        ]
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(GoalStatus.self, from: data)
    }
}

// MARK: - Network Error Enum
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
