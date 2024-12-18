//
//  GameCard.swift
//  SteadyFit
//
//  Created by Samuel Bechar on 11/8/24.
//

import SwiftUI
import HealthKit
import Charts
import CoreLocation


struct GameCard: View {
    let exerciseType: String
    let goal: Double
    let currentProgress: Double
    let healthStore: HealthStore?
    let gameCode : String
    let locManager = CLLocationManager()
    @State private var navigateToVerificationView = false
    
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
    
    // Fixed for circle chart
    private var fixedCurrentProgress: Double {
        if currentProgress > goal {
            return goal
        }
        return currentProgress
    }
    
    var body: some View {
        let data = [ // Outer Circle
            GraphDataPoint(
                day: "Mon",
                hours: Double(currentProgress)
            ),
            GraphDataPoint(
                day: "tues",
                hours:  Double(goal - fixedCurrentProgress)
            )
        ]
        
        NavigationLink(destination: LoadingView(), isActive: $navigateToVerificationView) {
            EmptyView()
        }
        VStack {
            HStack {
                Spacer()
                    Button {
                        // Declare currentLocation as an optional
                        var currentLocation: CLLocation?

                        // Check location authorization status
                        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                            currentLocation = locManager.location
                        } else {
                            print("Location services not authorized.")
                            return
                        }

                        // Safely unwrap currentLocation
                        guard let location = currentLocation else {
                            print("Unable to fetch current location.")
                            return
                        }
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
                                                print("longitude: ", currentLocation?.coordinate.longitude)
                                                print("lattitude: ", currentLocation?.coordinate.latitude)
                                               
                                                //SEND TO DB HERE
                                                healthStore.sendActivityToDB(gameCode: gameCode, activityType: activityType, durationInMinutes: Int(durationInMinutes), distanceText: finalDistance, latitude: currentLocation?.coordinate.latitude, longitude: currentLocation?.coordinate.longitude)
                                            }
                                        }
                                    }
                                    navigateToVerificationView = true
                                }
                            }
                        }
                    } label: {
                        ZStack{
                            Chart {
                                ForEach(data.indices, id: \.self) { index in
                                    let d = data[index]
                                    SectorMark(angle: .value("Hours", d.hours))
                                        .foregroundStyle(Color.customColor2(for: index))
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(width: 80, height: 80)
                            Circle()
                                .stroke(Color.deepBlue, lineWidth: 2)
                                .fill(.white)
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
                NavigationLink(destination: ActiveGameView(gameCode: gameCode, healthStore: healthStore)
                                .navigationBarBackButtonHidden(true)) {
                    VStack(alignment: .leading){
                        Spacer()
                        Text(exerciseType)
                            .font(.custom("Poppins-Bold", size: 15))
                        Spacer()
                        Text(exerciseAction + " " + goalText + " " + unit)
                        Text("Progress: \(currentProgressText) \(unit) / \(goalText) \(unit)")
                        Spacer()
                        Text("View Game Details >")
                            .foregroundColor(.deepBlue)
                            .font(.custom("Poppins-Bold", size: 10))
                            .padding(.bottom, 2)
                        
                        Spacer()
                    }
                }
                    .foregroundColor(.black)
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
        .onAppear {
            locManager.requestWhenInUseAuthorization()
        }
    }
}

#Preview {
    GameCard(exerciseType: "Running", goal: 10, currentProgress: 8.75, healthStore: HealthStore(), gameCode: "FpcVHDwe")
}
