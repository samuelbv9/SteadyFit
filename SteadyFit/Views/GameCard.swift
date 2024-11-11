//
//  GameCard.swift
//  SteadyFit
//
//  Created by Samuel Bechar on 11/8/24.
//

import SwiftUI
import HealthKit

struct GameCard: View {
    let exerciseType: String
    let goal: Double
    let currentProgress: Double
    let healthStore: HealthStore?
    let gameCode : String
    
    // Computed property to determine units based on exercise type
    private var unit: String {
        switch exerciseType.lowercased() {
        case "swimming":
            return "yds"
        case "running", "cycling", "walking":
            return "mi"
        case "strength training":
            return "times"
        default:
            return ""
        }
    }
    
    // Computed property to determine units based on exercise type
    private var exerciseAction: String {
        switch exerciseType.lowercased() {
        case "swimming":
            return "Swim"
        case "running":
            return "Run"
        case "cycling":
            return "Cycle"
        case "walking":
            return "Walk"
        case "strength training":
            return "Go to the gym"
        default:
            return ""
        }
    }
    
    // Formatting the goal and currentProgress values for display
    private var goalText: String {
        String(format: "%.2f", goal)
    }
    
    private var currentProgressText: String {
        String(format: "%.2f", currentProgress)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                    Button {
                        if let healthStore = healthStore {
                            //check if we have permmission to use metrics and if not request permission
                            healthStore.requestAuthorization { success in
                                if success {
                                    healthStore.calculateWorkouts(gameCode: gameCode) { workouts in
                                        if let workouts = workouts {
                                            //update UI
                                            for workout in workouts {
                                                // 1. Report Activity Type
                                                let activityType = workout.workoutActivityType.name
                                                
                                                // 2. Report Duration in Minutes
                                                let durationInMinutes = workout.duration / 60
                                                
                                                // 3. Report Distance (if available)
                                                var finalDistance : Double? = nil
                                                if let distance = workout.totalDistance {
                                                    if workout.workoutActivityType == .swimming {
                                                        finalDistance = distance.doubleValue(for: HKUnit.yard())
                                                    }
                                                    else {
                                                        finalDistance = distance.doubleValue(for: HKUnit.mile())
                                                    }
                                                }
                                               
                                                //Send this data to DB
                                                print("activityType: ", activityType)
                                                print("duration: ", durationInMinutes)
                                                print("distance: ", finalDistance ?? "nil")
                                               
                                                //SEND TO DB HERE
                                                healthStore.sendActivityToDB(gameCode: gameCode, activityType: activityType, durationInMinutes: Int(durationInMinutes), distanceText: finalDistance)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        ZStack{
                            Circle()
                                .stroke(Color.deepBlue, lineWidth: 2)
                                .frame(width: 57)
                            Text("Upload\n& Verify")
                                .foregroundColor(.deepBlue)
                                .font(.custom("Poppins-Bold", size: 10))
                        }
                    }
                Spacer()
                Rectangle()
                    .frame(width: 1, height: 82)
                    .foregroundColor(.lightGray)
                Spacer()
                VStack(alignment: .leading){
                    Spacer()
                    Text(exerciseType)
                        .font(.custom("Poppins-Bold", size: 15))
                    Spacer()
                    Text(exerciseAction + " " + goalText + " " + unit)
                    Text("Progress: \(currentProgressText) \(unit) / \(goalText) \(unit)")
                    Spacer()
                    NavigationLink(destination: ActiveGameView(gameCode: gameCode, healthStore: healthStore)) {
                        Text("View Game Details >")
                            .foregroundColor(.deepBlue)
                            .font(.custom("Poppins-Bold", size: 10))
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .font(.custom("Poppins-Regular", size: 10))
        .frame(width: 325, height: 119)
        .clipShape(.rect(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.deepBlue, lineWidth: 2)
        )
    }
}

#Preview {
    GameCard(exerciseType: "Running", goal: 10, currentProgress: 8.75, healthStore: HealthStore(), gameCode: "FpcVHDwe")
}
