//
//  GameCompletedView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 11/5/24.
//

import SwiftUI
import Foundation
import Charts
import Firebase
import FirebaseAuth

struct GameCompletedView: View {
    @StateObject private var viewModel = ActiveGameViewModel()
    let gameCode : String

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
        if gameData?.exerciseType == "strength training" {
            isStrengthTraining = true
        }
        var units = "miles"
        if gameData?.exerciseType == "swimming" {
            units = "yards"
        }
        
        let data = [ // Outer Circle
            GraphDataPoint(
                day: "Mon",
                hours: isStrengthTraining ?
                    Double(viewModel.gameData?.currentFrequency ?? 0) ?? 0 :
                    5.0
            ),
            GraphDataPoint(
                day: "tues",
                hours:  isStrengthTraining ?
                    Double(viewModel.gameData?.totalFrequency ?? 1) ?? 1 :
                    0
            )
        ]
        
        let convertedD: Double = Double(viewModel.gameData?.weekDistance ?? "0") ?? 0.0
        let convertedDgoal: Double = Double(viewModel.gameData?.weekDistanceGoal ?? "0") ?? 0.0
        let convertedF:  Double = Double(viewModel.gameData?.weekFrequency ?? 0) ?? 0.0
        let convertedFgoal:  Double = Double(viewModel.gameData?.weekFrequencyGoal ?? 0) ?? 0.0
        
        let data2 = [ // Inner Circle
            GraphDataPoint(
                day: "Mon",
                hours: 5
            ),
            GraphDataPoint(
                day: "tues",
                hours:  0
            )
        ]
        
        return VStack {
            HeaderView()
            Spacer()

            VStack {
                Text("Game Completed")
                    .font(.custom("Poppins-Bold", size: 30))
                    .kerning(-0.6) // Decreases letter spacing
                    .padding(.bottom, -16)
            }
            .padding(.bottom, -15)
            .padding(.top, -15)
            
            .padding(.top, 20)
            .padding(.bottom, 10)
            .frame(width: 322, alignment: .leading)
    
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
                            let currentFrequency = Double(viewModel.gameData?.currentFrequency ?? 0) ?? 0
                            let totalFrequency = Double(viewModel.gameData?.totalFrequency ?? 0) ?? 0
                            let percentage = isStrengthTraining ?
                                (currentFrequency / totalFrequency) * 100:
                                (5 / totalDistance) * 100
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
                            Text("5.00/\(gameData?.totalDistance ?? "err") \(units)")
                                .font(.custom("Poppins-Regular", size: 18))
                                .frame(width: 183, alignment: .leading)
                        }
                        Text("This Week")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 183, alignment: .leading)
                        //stats
                        // ####### HERE #############
                        if (isStrengthTraining) {
                            Text("5.00/\(gameData?.weekFrequencyGoal ?? 1) units")
                                .font(.custom("Poppins-Regular", size: 18))
                                .frame(width: 183, alignment: .leading)
                        } else {
                            Text("5.00/\(gameData?.weekDistanceGoal ?? "err") \(units)")
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
                        .frame(width: 130, alignment: .leading)
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
                        Text("$\(String(format: "%.2f", betData?.amountGained ?? 0))")
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
        }
    }
}

#Preview {
    GameCompletedView(gameCode: "Eo6Pav9I")
}

//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//struct CustomCircle: Shape {
//    var trimTo: CGFloat = 1
//    var rotation: Double = 0
//    var lineWidth: CGFloat = 1
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
//                    radius: min(rect.width, rect.height) / 2,
//                    startAngle: .degrees(0),
//                    endAngle: .degrees(360),
//                    clockwise: false)
//        return path
//            .trimmedPath(from: 0, to: trimTo)
//            .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
//            .applying(CGAffineTransform(rotationAngle: 90.0))
//    }
//}
//
//extension Color {
//    static func customColor(for index: Int) -> Color {
//        switch index {
//        case 0:
//            return .deepBlue
//        case 1:
//            return .darkGray
//        // Add more cases as needed
//        default:
//            return .gray
//        }
//    }
//    
//    static func customColor2(for index: Int) -> Color {
//        switch index {
//        case 0:
//            return .steadyBlue
//        case 1:
//            return .lightGray
//        // Add more cases as needed
//        default:
//            return .gray
//        }
//    }
//}
