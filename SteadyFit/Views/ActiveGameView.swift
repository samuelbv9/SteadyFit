//
//  ActiveGameView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 11/1/24.
//
// TODO:
// Take in a game code and change the .onAppear block at bottom.
// Use correct variables (totalDistanceGoal) for showing numbers
// Add real money data

import SwiftUI
import Foundation
import Charts
import Firebase
import FirebaseAuth
import HealthKit
import CoreLocation

struct ActiveGameView: View {
    @StateObject private var viewModel = ActiveGameViewModel()
    let gameCode : String
    let healthStore: HealthStore?
    @State private var navigateToVerificationView = false
    let locManager = CLLocationManager()


//    //initialize instance of class HealthStore
//    private var healthStore: HealthStore?
//    
//    init() {
//        healthStore = HealthStore()
//    }
    
    var body: some View {
        let gameData = viewModel.gameData
        let betData = viewModel.betDetails
        var isStrengthTraining = false
        if gameData?.exerciseType.lowercased() == "strength training" {
            isStrengthTraining = true
        }
        var units = "mi"
        if gameData?.exerciseType.lowercased() == "swimming" {
            units = "yds"
        }
        
        var currentF = Double(viewModel.gameData?.currentFrequency ?? 0)
        var currentD = Double(viewModel.gameData?.currentDistance ?? "0") ?? 0
        let currentFgoal = Double(viewModel.gameData?.totalFrequency ?? 1)
        let currentDgoal = Double(viewModel.gameData?.totalDistance ?? "1") ?? 1
        if (!isStrengthTraining && (currentD > currentDgoal)) {
            currentD = currentDgoal
        }
        else if (isStrengthTraining && (currentF > currentFgoal)) {
            currentF = currentFgoal
        }
      
        var currentLocation: CLLocation!  
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locManager.location
        }
        
        let data = [ // Outer Circle
            GraphDataPoint(
                day: "Mon",
                hours: isStrengthTraining ? 
                    currentF :
                    currentD
            ),
            GraphDataPoint(
                day: "tues",
                hours:  isStrengthTraining ?
                    currentFgoal - currentF :
                    currentDgoal - currentD
            )
        ]
        
        var convertedD: Double = Double(viewModel.gameData?.weekDistance ?? "0") ?? 0.0
        let convertedDgoal: Double = Double(viewModel.gameData?.weekDistanceGoal ?? "1") ?? 1.0
        var convertedF:  Double = Double(viewModel.gameData?.weekFrequency ?? 0)
        let convertedFgoal:  Double = Double(viewModel.gameData?.weekFrequencyGoal ?? 1)
        
        if (!isStrengthTraining && (convertedD > convertedDgoal)) {
            convertedD = convertedDgoal
        }
        else if (isStrengthTraining && (convertedF > convertedFgoal)) {
            convertedF = convertedFgoal
        }
        
        
        let data2 = [ // Inner Circle
            GraphDataPoint(
                day: "Mon",
                hours: isStrengthTraining ?
                    convertedF :
                    convertedD
            ),
            GraphDataPoint(
                day: "tues",
                hours:  isStrengthTraining ?
                    convertedFgoal - convertedF :
                    convertedDgoal - convertedD
            )
        ]
        

        
        
        return VStack {
            NavigationLink(destination: LoadingView(), isActive: $navigateToVerificationView) {
                EmptyView()
            }
            HeaderView()
            Spacer()

            HStack { // Game title and back button
                NavigationLink(destination: HomeView()
                    .navigationBarBackButtonHidden(true)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .foregroundColor(Color.deepBlue)
                            .frame(height: 30)
                            .frame(width: 35)
                        Text("<")
                            .foregroundColor(Color.white)
                    }
                }
                VStack {
                    Text(gameData?.exerciseType.capitalized ?? "no game data")
                        .font(.custom("Poppins-Bold", size: 30))
                        .kerning(-0.6) // Decreases letter spacing
                        .padding(.bottom, -16)
                    Text(gameCode)
                        .font(.custom("Poppins-Bold", size: 25))
                        .kerning(-0.6) // Decreases letter spacing
                }
                .padding(.bottom, -15)
                .padding(.top, -15)
                .padding(.leading, 30)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            .frame(width: 322, alignment: .leading)
            
            Spacer()
            
            VStack { // Your adaptive goal
                Text("Your Adaptive Goal")
                    .font(.custom("Poppins-Bold", size: 20))
                    .kerning(-0.6) // Decreases letter spacing
                    .frame(maxWidth: 320, alignment: .leading)
                    .padding(.bottom, -5)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.deepBlue, lineWidth: 2)
                        .frame(height: 150)
                        .frame(width:322)
                    VStack{
                        HStack {
                            Text("Distance") // This will need to change based on game
                                .font(.custom("Poppins-Bold", size: 20))
                                .kerning(-0.3) // Decreases letter spacing
                                //.frame(maxWidth: 300, alignment: .leading)
                                .padding(.leading, 15)
                            Spacer()
                            // ####### HERE #############
                            if (isStrengthTraining) { // Show correct units
                                Text("\(gameData?.weekFrequencyGoal ?? 0) times") // week distance goal
                                    .padding(.trailing, 20)
                                    .font(.custom("Poppins-Regular", size: 18))
                                    .kerning(-0.3)
                            } else {
                                Text("\(gameData?.weekDistanceGoal ?? "err") \(units)")
                                    .padding(.trailing, 20)
                                    .font(.custom("Poppins-Regular", size: 18))
                                    .kerning(-0.3)
                            }
                        }
                        HStack {
                            Text("Current Progress") // This will need to change based on game
                                .font(.custom("Poppins-Bold", size: 20))
                                .kerning(-0.3) // Decreases letter spacing
                                .padding(.leading, 15)
                            Spacer()
                            // ####### HERE #############
                            if (isStrengthTraining) { // Show correct units
                                Text("\(gameData?.weekFrequency ?? 0) times") // week distance
                                    .padding(.trailing, 20)
                                    .font(.custom("Poppins-Regular", size: 18))
                                    .kerning(-0.3)
                            } else {
                                Text("\(gameData?.weekDistance ?? "err") \(units)")
                                    .padding(.trailing, 20)
                                    .font(.custom("Poppins-Regular", size: 18))
                                    .kerning(-0.3)
                            }
                        }
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
                                                    print("longitude: ", currentLocation.coordinate.longitude)
                                                    print("lattitude: ", currentLocation.coordinate.latitude)
                                                   
                                                    //SEND TO DB HERE
                                                    healthStore.sendActivityToDB(gameCode: gameCode, activityType: activityType, durationInMinutes: Int(durationInMinutes), distanceText: finalDistance, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                                                }
                                            }
                                        }
                                        navigateToVerificationView = true
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 0)
                                    .foregroundColor(Color.deepBlue)
                                    .frame(height: 50)
                                    .frame(width: 324)
                                    .clipShape(RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight]))
                                HStack {
                                    Text("Upload & Verify Workout")
                                        .foregroundColor(Color.white)
                                        .padding(.leading, 20)
                                        .font(.custom("Poppins-SemiBold", size: 15))
                                        .kerning(-0.3)
                                    Spacer()
                                    Image("check-white")
                                        .padding(.trailing, 20)
                                    
                                }
                                
                            }
                        }
                        .padding(.bottom, -25)
                    }
                    .frame(width: 322, height: 150)
                }
            }
            
            Spacer()
            
            VStack { // PARTICIPANTS
                Text("Participants")
                    .font(.custom("Poppins-Bold", size: 20))
                    .kerning(-0.6) // Decreases letter spacing
                    .frame(width: 320, alignment: .leading)
                HStack {
                    Image("profile-example")
                        .frame(width: 45, height: 45)
                        .padding(.top, -10)
                    Image("profile-example")
                        .frame(width: 45, height: 45)
                        .padding(.top, -10)
                }
                .frame(width: 322, alignment: .leading)
            }
            .frame(width: 322)
            .padding(.top, 10)
            .padding(.bottom, 0)
            
            Spacer()
            
            VStack { // Overall Stats
                Text("Overall Statistics")
                    .font(.custom("Poppins-Bold", size: 20))
                    .kerning(-0.6) // Decreases letter spacing
                    .padding(.bottom, -5)
                HStack{
                    // Circle completion percent pie chart
                    VStack{
                        ZStack {
                            Chart {
                                ForEach(data.indices, id: \.self) { index in
                                    let d = data[index]
                                    SectorMark(angle: .value("Hours", d.hours))
                                        .foregroundStyle(Color.customColor(for: index))
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(width: 100, height: 100)
                            
                            Chart {
                                ForEach(data.indices, id: \.self) { index in
                                    let d = data2[index]
                                    SectorMark(angle: .value("Hours", d.hours))
                                        .foregroundStyle(Color.customColor2(for: index))
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(width: 75, height: 75)
                            
                            Circle()
                                .trim(from: 0, to: 1) // weekly goal
                                .foregroundColor(Color.white)
                                .frame(width: 50, height: 50)
                            let currentDistance = Double(viewModel.gameData?.currentDistance ?? "0") ?? 0
                            let totalDistance = Double(viewModel.gameData?.totalDistance ?? "1") ?? 1
                            let currentFrequency = Double(viewModel.gameData?.currentFrequency ?? 0)
                            let totalFrequency = Double(viewModel.gameData?.totalFrequency ?? 0)
                            let percentage = isStrengthTraining ?
                                (currentFrequency / totalFrequency) * 100:
                                (currentDistance / totalDistance) * 100
                            Text("\(String(format: "%.1f", percentage))%")
                                .font(.custom("Poppins-Bold", size: 14))
                                .kerning(-0.6)
                        }
                        .frame(width: 100, height: 100)
                    }
                    .padding(.trailing, 20)
                    
                    Image("chart-line")
                    
                    VStack {
                        Text("Overall Completion")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 183, alignment: .leading)
                        //stats
                        // ####### HERE #############
                        if (isStrengthTraining) {
                            Text("\(gameData?.currentFrequency ?? 0)/\(gameData?.totalFrequency ?? 0) times")
                                .font(.custom("Poppins-Regular", size: 18))
                                .frame(width: 183, alignment: .leading)
                        } else {
                            Text("\(gameData?.currentDistance ?? "err")/\(gameData?.totalDistance ?? "err") \(units)")
                                .font(.custom("Poppins-Regular", size: 18))
                                .frame(width: 183, alignment: .leading)
                        }
                        Text("This Week")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 183, alignment: .leading)
                        //stats
                        // ####### HERE #############
                        if (isStrengthTraining) {
                            Text("\(gameData?.weekFrequency ?? 1)/\(gameData?.weekFrequencyGoal ?? 1) times")
                                .font(.custom("Poppins-Regular", size: 18))
                                .frame(width: 183, alignment: .leading)
                        } else {
                            Text("\(gameData?.weekDistance ?? "err")/\(gameData?.weekDistanceGoal ?? "err") \(units)")
                                .font(.custom("Poppins-Regular", size: 18))
                                .frame(width: 183, alignment: .leading)
                        }
                    }
                    .padding(.leading, 20)
                }
            }
            
            Spacer()
            
            HStack { // Total Balance
                VStack {
                    let currentBalance = (betData?.balance ?? 0) + (betData?.initialBet ?? 0)
                    Text("Total Balance")
                        .font(.custom("Poppins-Light", size: 12))
                    // Format the dollar amount to two decimal places with a dollar sign
                    Text("$\(String(format: "%.2f", currentBalance))")
                        .font(.custom("Poppins-Bold", size: 27))
                        .frame(width: 130, alignment: .center)
                }
                
                Image("chart-line")
                
                VStack {
                    ZStack {
                        Text("Initial Bet: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        // Format the initial bet to two decimal places with a dollar sign
                        Text("$\(String(format: "%.2f", betData?.initialBet ?? 0))")
                            .font(.custom("Poppins-Regular", size: 18))
                            .padding(.leading, 60)
                            .frame(width: 130, alignment: .leading)
                    }
                    ZStack {
                        Text("Lost: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        // Format the amount lost to two decimal places with a dollar sign
                        Text("$\(String(format: "%.2f", betData?.amountLost ?? 0))")
                            .font(.custom("Poppins-Regular", size: 18))
                            .frame(width: 130, alignment: .leading)
                            .padding(.leading, 25)
                    }
                    ZStack {
                        Text("Gained: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        // Format the amount gained to two decimal places
                        Text(String(format: "%.2f", betData?.amountGained ?? 0))
                            .font(.custom("Poppins-Regular", size: 18))
                            .frame(width: 130, alignment: .leading)
                            .padding(.leading, 80)
                    }
                }
                .padding(.leading, 20)
                .frame(width: 212)
            }
            .padding(.bottom, 10)
            
            Spacer()
            NavBarView(viewIndex: 4)
        }
        //.frame(maxHeight: .infinity, alignment: .top)
        .frame(width: 350)
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.loadCurrentGame(userId: Auth.auth().currentUser?.uid ?? "", gameCode: gameCode)
            viewModel.loadBetDetails(gameCode: gameCode)
            locManager.requestWhenInUseAuthorization()
        }
    }
}

#Preview {
    ActiveGameView(gameCode: "NODqAbjW", healthStore: HealthStore())
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


extension Color {
    static func customColor(for index: Int) -> Color {
        switch index {
        case 0:
            return .deepBlue
        case 1:
            return .darkGray
        // Add more cases as needed
        default:
            return .darkGray
        }
    }
    
    static func customColor2(for index: Int) -> Color {
        switch index {
        case 0:
            return .steadyBlue
        case 1:
            return .lightGray
        // Add more cases as needed
        default:
            return .lightGray
        }
    }
}

// Helper extension for workout activity type names
extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .traditionalStrengthTraining: return "Strength Training"
        default: return "Other Activity"
        }
    }
}
