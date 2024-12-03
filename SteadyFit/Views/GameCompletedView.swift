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
    @StateObject private var viewModel = CompletedGameViewModel()
    let gameCode : String

//    //initialize instance of class HealthStore
//    private var healthStore: HealthStore?
//
//    init() {
//        healthStore = HealthStore()
//    }
    
    var body: some View {
        let gameData = viewModel.gameData
        // let betData = viewModel.betDetails
        var isStrengthTraining = false
        if gameData?.gameData.exercisetype == "strength training" {
            isStrengthTraining = true
        }
        var units = "miles"
        if gameData?.gameData.exercisetype == "swimming" {
            units = "yards"
        }
        
        let currentUserParticipantData = viewModel.getCurrentUserParticipantData()
        
        let currentDistance = Double(currentUserParticipantData?.totalDistance ?? "0") ?? 0
        let totalDistance = Double(viewModel.gameData?.gameData.distance ?? "1") ?? 1
        let currentFrequency = Double(currentUserParticipantData?.totalFrequency ?? 0)
        let totalFrequency = Double(viewModel.gameData?.gameData.frequency ?? "0") ?? 1
        let percentage = isStrengthTraining ?
            (currentFrequency / totalFrequency) * 100:
            (currentDistance / totalDistance) * 100
        
        let data = [ // Ring
            GraphDataPoint(
                day: "Mon",
                hours: isStrengthTraining ?
                currentFrequency : currentDistance
            ),
            GraphDataPoint(
                day: "tues",
                hours:  isStrengthTraining ?
                totalFrequency - currentFrequency : totalDistance - currentDistance
            )
        ]
        
        return VStack {
            HeaderView()
                .padding(.bottom, 15)
           // Spacer()

            VStack {
                Text("Game Completed")
                    .font(.custom("Poppins-Bold", size: 30))
                    .kerning(-0.6) // Decreases letter spacing
                    .padding(.bottom, -5)
                Text(viewModel.gameData?.gameData.exercisetype ?? "Error")
                    .font(.custom("Poppins-SemiBold", size: 20))
            }
            .padding(.bottom, -15)
            .padding(.top, -15)
            .padding(.top, 20)
            .padding(.bottom, 10)
            .frame(width: .infinity, alignment: .center)
    
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
                            
                            Circle()
                                .trim(from: 0, to: 1) // weekly goal
                                .foregroundColor(Color.white)
                                .frame(width: 70, height: 70)
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
                            Text("\(String(format: "%.2f", currentFrequency))/\(String(format: "%.2f", totalFrequency)) times")
                                .font(.custom("Poppins-Regular", size: 18))
                                .frame(width: 183, alignment: .leading)
                        } else {
                            Text("\(String(format: "%.2f", currentDistance))/\(String(format: "%.2f", totalDistance)) \(units)")
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
                    let betAmount = Double(gameData?.gameData.betamount ?? "0.0") ?? 0.0
                    let currentBalance = (Double(currentUserParticipantData?.balance ?? "0.0") ?? 0.0) + betAmount
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
                        Text("$\(String(format: "%.2f", gameData?.gameData.betamount ?? 0 ))")
                            .font(.custom("Poppins-Regular", size: 18))
                            .padding(.leading, 60)
                            .frame(width: 130, alignment: .leading)
                    }
                    ZStack {
                        Text("Lost: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        // Format the amount lost to two decimal places with a dollar sign
                        Text("$\(String(format: "%.2f", currentUserParticipantData?.amountLost ?? 0))")
                            .font(.custom("Poppins-Regular", size: 18))
                            .frame(width: 130, alignment: .leading)
                            .padding(.leading, 25)
                    }
                    ZStack {
                        Text("Gained: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        // Format the amount gained to two decimal places
                        Text("$\(String(format: "%.2f", currentUserParticipantData?.amountGained ?? 0))")
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
            VStack {
                Text("Final Gain/Loss By User")
                    .font(.custom("Poppins-Bold", size: 20))
                    .padding(.bottom, 2)
                if let participants = viewModel.gameData?.participantsData {
                    ForEach(participants, id: \.userId) { participant in
                        Text(participant.email + ": $" + participant.balance)
                            .font(.custom("Poppins-Regular", size: 15))
                    }
                }
            }
            Spacer()
            NavBarView(viewIndex: 4)
        }
        //.frame(maxHeight: .infinity, alignment: .top)
        .frame(width: 350)
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.loadPastGame(gameCode: gameCode)
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

