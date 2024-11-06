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


final class GamesStore {
    static let shared = GamesStore()
    private(set) var activeGames = [Game]()
    private(set) var pastGames = [Game]()
    private var isRetrieving = false
    private let synchronized = DispatchQueue(label: "synchronized", qos: .background)
    let serverUrl = "http://52.200.16.208/"
    
    func getBetBalances(_ gameCode: String) {
        // serial retrievals
        var proceed = false
        synchronized.sync {
            if !self.isRetrieving {
                proceed = true
                self.isRetrieving = true
            }
        }
        guard proceed else {
            return
        }

        guard let apiUrl = URL(string: "\(serverUrl)bet_details/?game_code=\(gameCode)") else {
            print("bet_details: Bad URL")
            return
        }
        print(apiUrl)
        
        DispatchQueue.global(qos: .background).async {
            var request = URLRequest(url: apiUrl)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { // allow subsequent retrieval
                    self.synchronized.async {
                        self.isRetrieving = false
                    }
                }
                guard let data = data, error == nil else {
                    print("getBetBalances: NETWORKING ERROR")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("getBetBalances: HTTP STATUS: \(httpStatus.statusCode)")
                    return
                }
                
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    print("getBetBalances: failed JSON deserialization")
                    return
                }
                
                var balances: [String: Double] = [:]

                for entry in jsonObj {
                    if let userId = entry["userId"] as? String {
                        // Ensure balance is a Double, even if it's a String in JSON
                        if let balanceString = entry["balance"] as? String, let balance = Double(balanceString) {
                            balances[userId] = balance
                        }
                    }
                }
                print("yasss??? \(balances)")
                
            }.resume()
        }
        
    }
    
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
