//
//  Game.swift
//  SteadyFit
//
//  Created by Debbie Shih on 11/3/24.
//

import Foundation
import FirebaseAuth
import SwiftUI
import CoreLocation

struct Game {
    var gameCode: String
    var betAmount: Double
    var exerciseType: String
    var frequency: Int?
    var distance: Double?
    var frequencyGoal: Int?
    var distanceGoal: Double?
    var duration: Int
    var adaptiveGoals: Bool?
    var startDate: Date

    // easy comparison
    static func ==(lhs: Game, rhs: Game) -> Bool {
        lhs.gameCode == rhs.gameCode
    }
}

struct UserProgress: Decodable {
    var currentDistance: String?
    var currentFrequency: Int?
    var currentBalance: Double
}

final class GamesStore: ObservableObject {
    private let geocoder = CLGeocoder()
    static let shared = GamesStore()
    @Published private(set) var activeGames: [Game] = []
    @Published private(set) var pastGames: [Game] = []
    private var isRetrieving = false
    private let synchronized = DispatchQueue(label: "synchronized", qos: .background)
    let serverUrl = "http://52.200.16.208/"
    
    func getActiveGames(userId: String) async {
           guard let url = URL(string: "https://52.200.16.208/active_games/?user_id=\(userId)") else {
               return
           }
           do {
               let (data, _) = try await URLSession.shared.data(from: url)
               let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
               
               guard let activeGamesArray = responseDict?["active_games"] as? [[String: Any]] else {
                   return
               }

               var games: [Game] = []

               for game in activeGamesArray {
                   if let exerciseType = game["exerciseType"] as? String,
                      let gameCode = game["gameCode"] as? String {
                       let weekFrequency = game["weekFrequency"] as? Int
                       let weekFrequencyGoal = game["weekFrequencyGoal"] as? Int
                       let weekDistance = game["weekDistance"] as? String ?? "0.00"
                       let weekDistanceGoal = game["weekDistanceGoal"] as? String ?? "0.00"
                       
                       let tempGame = Game(
                           gameCode: gameCode,
                           betAmount: 0.0,
                           exerciseType: exerciseType,
                           frequency: weekFrequency,
                           distance: Double(weekDistance),
                           frequencyGoal: weekFrequencyGoal,
                           distanceGoal: Double(weekDistanceGoal),
                           duration: 0,
                           adaptiveGoals: nil,
                           startDate: Date()
                       )
                       games.append(tempGame)
                   }
               }
               // Update UI on main thread
               DispatchQueue.main.async {
                   self.activeGames = games
               }
           } catch {
               print("Error fetching active games: \(error.localizedDescription)")
           }
       }
    
    // USE THE past_games API TO STORE PAST GAMES
    // DISPLAY THOSE ON THE PROFILE PAGE
    // Just like it is done for active_game
//  Response format:
//    {
//        "past_games":
//            [
//                {
//                    "gameCode": game_code,
                //    "exerciseType": exercise_type,
                //    "duration": duration,
                //    "betAmount": float(bet_amount),
                //    "completed": time_completed
//                }, ...
//            ]
//    }
    
    // TODO: Figure out "completed" and show it??
    func getPastGames(userId: String) async {
        guard let url = URL(string: "https://52.200.16.208/past_games/?user_id=\(userId)") else {
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            guard let pastGamesArray = responseDict?["past_games"] as? [[String: Any]] else {
                return
            }

            var games: [Game] = []

            for game in pastGamesArray {
                if let exerciseType = game["exerciseType"] as? String,
                   let gameCode = game["gameCode"] as? String,
                   let duration = game["duration"] as? Int,
                    let betAmount = game["betAmount"] as? Double {
                    
                    let tempGame = Game(
                        gameCode: gameCode,
                        betAmount: betAmount,
                        exerciseType: exerciseType,
                        frequency: 0,
                        distance: 0,
                        frequencyGoal: 0,
                        distanceGoal: 0,
                        duration: duration,
                        adaptiveGoals: nil,
                        startDate: Date()
                    )
                    games.append(tempGame)
                }
            }
            // Update UI on main thread
            DispatchQueue.main.async {
                self.pastGames = games
            }
        } catch {
            print("Error fetching past games: \(error.localizedDescription)")
        }
    }
    
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
    
    func joinGame(_ gameCode: String, _ password: String, _ address: String) {
        
        if address.isEmpty {
            self.performJoinGameRequest(gameCode: gameCode, password: password, longitude: 0, latitude: 0)
        }
        else {
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let location = placemarks?.first?.location else {
                    print("No coordinates found for this address.")
                    return
                }
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                print("Lat: \(latitude) Long: \(longitude)")
                
                self.performJoinGameRequest(gameCode: gameCode, password: password, longitude: longitude, latitude: latitude)
            }
        }
    }
    
    func performJoinGameRequest(gameCode: String, password: String, longitude: Double, latitude: Double) {
        let json_latitude: Double? = latitude == 0 ? nil : latitude
        let json_longitude: Double? = longitude == 0 ? nil : longitude
        
        
        var jsonObj: [String: Any?] = [
            "user_id": Auth.auth().currentUser?.uid,
            "game_code": gameCode,
            "latitude": json_latitude,
            "longitude": json_longitude
        ]
        
        // deal with nil values
        var filteredJsonObj = jsonObj.compactMapValues { $0 }
                
        if password != "" {
            filteredJsonObj["password"] = password
        }
            
        guard let jsonData = try? JSONSerialization.data(withJSONObject: filteredJsonObj) else {
           print("joinGame: jsonData serialization error")
           return
       }

       guard let apiUrl = URL(string: "\(serverUrl)join_game/") else {
           print("joinGame: Bad URL")
           return
       }

       DispatchQueue.global(qos: .background).async {
           var request = URLRequest(url: apiUrl)
           request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
           request.httpMethod = "POST"
           request.httpBody = jsonData

           URLSession.shared.dataTask(with: request) { data, response, error in
               guard let _ = data, error == nil else {
                   print("joinGame: NETWORKING ERROR")
                   return
               }
               if let httpStatus = response as? HTTPURLResponse {
                   if httpStatus.statusCode != 200 {
                       print("joinGame: HTTP STATUS: \(httpStatus.statusCode)")
                       return
                   } else {
                       print("Game joined successfully")
                   }
               }
           }.resume()
       }
    }
    
    
    func postGame(_ game: UserData, completion: @escaping (Bool) -> Void) {
        if game.address.isEmpty {
            self.performPostRequest(game: game, latitude: 0, longitude: 0, completion: completion)
        } else {
            geocoder.geocodeAddressString(game.address) { placemarks, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let location = placemarks?.first?.location else {
                    print("No coordinates found for this address.")
                    completion(false)
                    return
                }
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                print("Lat: \(latitude) Long: \(longitude)")
                
                self.performPostRequest(game: game, latitude: latitude, longitude: longitude, completion: completion)
            }
        }
    }
    
    func performPostRequest(game: UserData, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        // Create a Date object (current date)
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        let password: String? = game.password.isEmpty ? nil : game.password
        let json_latitude: Double? = latitude == 0 ? nil : latitude
        let json_longitude: Double? = longitude == 0 ? nil : longitude
        
        let jsonObj: [String: Any?] = [
            "user_id": Auth.auth().currentUser?.uid,
            "bet_amount": game.wagerInt,
            "exercise_type": game.selectedExerciseOption,
            "frequency": game.frequencyInt,
            "distance": game.distanceInt,
            "duration": game.durationInt,
            "adaptive_goals": game.adaptiveGoalsChecked,
            "start_date": dateString,
            "password" : password,
            "latitude": json_latitude,
            "longitude": json_longitude
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
                   completion(false)
                   return
               }
               if let httpStatus = response as? HTTPURLResponse {
                   if httpStatus.statusCode != 200 {
                       print("postGame: HTTP STATUS: \(httpStatus.statusCode)")
                       completion(false)
                       return
                   } else {
                       print("Completed")
                       completion(true)
                   }
               }
           }.resume()
       }
    }
    func postFitnessSurvey(_ data: FitnessSurveyData) {
        print(data)
    }
}
