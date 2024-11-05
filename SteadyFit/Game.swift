//
//  Game.swift
//  SteadyFit
//
//  Created by Debbie Shih on 11/3/24.
//

import Foundation

struct Game {
    var gameCode: String
    var betAmount: Double
    var exerciseType: String
    var frequency: Int?
    var distance: Double?
    var duration: Int
    var adaptiveGoals: Bool
    var startDate: Date
    
    // easy comparison
    static func ==(lhs: Game, rhs: Game) -> Bool {
        lhs.gameCode == rhs.gameCode
    }
}

struct userProgress {
    var currentDistance: Double
    var currentFrequency: Int
    var totalDistance: Double
    var totalFrequency: Int
}


final class GamesStore {
    static let shared = GamesStore()
    private(set) var activeGames = [Game]()
    private(set) var pastGames = [Game]()
    
    let serverUrl = "http://52.200.16.208/"
    
    func postGame(_ game: UserData) {

        // Create a Date object (current date)
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        
        let jsonObj: [String: Any?] = [
            "user_id": "8503f31c-8c1f-45eb-a7dd-180095aad816",
            "bet_amount": game.wagerInt,
            "exercise_type": game.selectedExerciseOption,
            "frequency": game.frequencyInt,
            "distance": game.distanceInt,
            "duration": game.durationInt,
            "adaptive_goals": game.adaptiveGoalsChecked,
            "start_date": dateString
        ]
        // deal with nil values
        let filteredJsonObj = jsonObj.compactMapValues { $0 }

       guard let jsonData = try? JSONSerialization.data(withJSONObject: filteredJsonObj) else {
           print("postGame: jsonData serialization error")
           return
       }

       guard let apiUrl = URL(string: "\(serverUrl)create_game/") else {
           print("postChatt: Bad URL")
           return
       }

       DispatchQueue.global(qos: .background).async {
           var request = URLRequest(url: apiUrl)
           request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
           request.httpMethod = "POST"
           request.httpBody = jsonData

           URLSession.shared.dataTask(with: request) { data, response, error in
               guard let _ = data, error == nil else {
                   print("postGame: NETWORKING ERROR")
                   return
               }

               if let httpStatus = response as? HTTPURLResponse {
                   if httpStatus.statusCode != 200 {
                       print("postGame: HTTP STATUS: \(httpStatus.statusCode)")
                       return
                   } else {
                       print("Completed")
                   }
               }

           }.resume()
       }
   }
}
