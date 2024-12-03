//
//  HealthStore.swift
//  SteadyFitAppleHealth
//
//  Created by Samuel Bechar on 10/31/24.
//

import Foundation
import HealthKit
import FirebaseAuth

class HealthStore {
    
    var healthStore : HKHealthStore?
    var query: HKSampleQuery?
    
    let activityDict: [String: HKWorkoutActivityType] = [
        "Running": HKWorkoutActivityType.running,
        "Walking": HKWorkoutActivityType.walking,
        "Cycling": HKWorkoutActivityType.cycling,
        "Swimming": HKWorkoutActivityType.swimming,
        "Strength Training": HKWorkoutActivityType.traditionalStrengthTraining
    ]
    
    //initialize healthstore
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    
    // This function requests user authorization for apple health
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        let workoutType = HKObjectType.workoutType()
        
        guard let healthStore = self.healthStore else { return completion(false)}
        
        healthStore.requestAuthorization(toShare: [], read: [workoutType]) { (success, error) in
            completion(success)
        }
        
    }
    
    // This function gets the last time data was uploaded. This way we can filter for workouts completed
    // after this date so we only get new workouts and don't accidentally double count any.
    func fetchLastUploadDate(userId: String, gameCode: String, completion: @escaping (Date?) -> Void) {
        guard let url = URL(string: "https://52.200.16.208/last_upload/?user_id=\(userId)&game_code=\(gameCode)") else {
            print("Invalid URL")
            completion(nil)
            return
        }
                
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch last upload time: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let responseDict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            let lastUploadString = responseDict!["timestamp"] as? String
            
            
            guard let data = data else {
                print("No data returned")
                completion(nil)
                return
            }
            
            guard let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let lastUploadString = responseDict["timestamp"] as? String else {
                    print("Failed to parse response dictionary")
                    completion(nil)
                    return
                }
                    
                print("Last upload string: \(lastUploadString)") // Debug print
            
                // Use DateFormatter instead of ISO8601DateFormatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" // Custom date format for parsing
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set timezone if necessary

                if let lastUpload = dateFormatter.date(from: lastUploadString) {
                    completion(lastUpload)
                } else {
                    print("Failed to parse last upload time from string: \(lastUploadString)")
                    completion(nil)
                }
        }
        task.resume()
    }
    
    // This function gets the activity type for a specific game using the game code. This will help us filter
    // through our workouts for only relevant ones to the game.
    func getActivityType(gameCode: String, completion: @escaping (HKWorkoutActivityType?) -> Void) {
        // Define the URL for the endpoint
        guard let url = URL(string: "https://52.200.16.208/get_activity_type?game_code=\(gameCode)") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch activity type: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data,
                  let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let exerciseTypeString = responseDict["exercise_type"] as? String else {
                print("Failed to parse activity type response")
                completion(nil)
                return
            }
            
            // Convert the exercise type string to HKWorkoutActivityType
            let activityType = self.activityDict[exerciseTypeString]
            completion(activityType)
        }
        
        task.resume()
    }
    
    // This function is what actually calculates the relevant workouts
    func calculateWorkouts(gameCode: String, completion: @escaping ([HKWorkout]?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No active user = error")
            return
        }

        // Fetch the last upload date
        fetchLastUploadDate(userId: userId, gameCode: gameCode) { lastUpload in
            guard let lastUpload = lastUpload else {
                print("Failed to get last upload date")
                completion(nil)
                return
            }
            
            // Get the activity type for the game code
            self.getActivityType(gameCode: gameCode) { activityType in
                guard let activityType = activityType else {
                    print("Failed to get activity type")
                    completion(nil)
                    return
                }
                        
                // Create predicates for the query
                let datePredicate = HKQuery.predicateForSamples(withStart: lastUpload, end: Date(), options: .strictStartDate)
                let workoutTypePredicate = HKQuery.predicateForWorkouts(with: activityType)
                
                // Combine the predicates to filter workouts in the specified date range and activity type
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, workoutTypePredicate])
                
                self.query = HKSampleQuery(sampleType: workoutType, predicate: compoundPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil, resultsHandler: { query, samples, error in
                    guard error == nil else {
                        print("Error fetching workouts: \(error!.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    // Convert samples to HKWorkout array and return
                    let workouts = samples as? [HKWorkout]
                    completion(workouts)
                })
                
                if let healthStore = self.healthStore, let query = self.query {
                    healthStore.execute(query)
                }
            }
        }
    }
    
    // This function sends a specific workout to the database
    func sendActivityToDB(gameCode: String, activityType: String, durationInMinutes: Int, distanceText: Double?, latitude: Double?, longitude: Double?) {
        // Define the URL for the endpoint
        guard let url = URL(string: "https://52.200.16.208/add_workout/") else {
            print("Invalid URL")
            return
        }
                
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No active user = error")
            return
        }
                
        // Prepare the data to be sent in JSON format
        var data: [String: Any] = [
            "user_id": userId,
            "game_code": gameCode,
            "activity_type": activityType,
            "duration": durationInMinutes,
        ]
        
        if let distance = distanceText {
            data["distance"] = distance
        }
        
        if latitude != nil && longitude != nil {
            data["latitude"] = latitude
            data["longitude"] = longitude
        }
                
        // Convert the data dictionary to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
                
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send workout to DB: \(error.localizedDescription)")
                return
            }
                    
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Workout successfully added to the database")
            } else {
                print("Failed to add workout: \(String(describing: response))")
            }
        }
        
        task.resume()
    }
    
}
