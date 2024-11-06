//
//  GameCompletedView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 11/5/24.
//

import SwiftUI
import Foundation
import Charts

struct GameCompletedView: View {
    @StateObject private var viewModel = ActiveGameViewModel()
    
    var body: some View {
        let data = [ // This will be for the circle chart
            SleepDataPoint(
                day: "Mon",
                hours: Double(viewModel.gameData?.currentDistance ?? "0") ?? 0
            ),
            SleepDataPoint(
                day: "tues",
                hours:  Double(viewModel.gameData?.totalDistance ?? "1") ?? 1
            )
        ]
        
        let data2 = [ // This will be for the circle chart
            SleepDataPoint(
                day: "Mon",
                hours: Double(viewModel.gameData?.currentFrequency ?? 0)
            ),
            SleepDataPoint(
                day: "tues",
                hours:  Double(viewModel.gameData?.totalFrequency ?? 1)
            )
        ]
        
        return VStack {
            HeaderView()
            Spacer()

            let gameData = viewModel.gameData
            
            
            Text("Game Completed")
                .font(.custom("Poppins-Bold", size: 30))
                .kerning(-0.6) // Decreases letter spacing
                .padding(.top, 20)
            
            Spacer()
            
            VStack { // Overall Stats
                Text("Overall Statistics")
                    .font(.custom("Poppins-Bold", size: 20))
                    .kerning(-0.6) // Decreases letter spacing
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
                            let percentage = (currentDistance / totalDistance) * 100
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
                        Text("\(gameData?.currentDistance ?? "err")/\(gameData?.totalDistance ?? "err") units")
                            .font(.custom("Poppins-Regular", size: 18))
                            .frame(width: 183, alignment: .leading)
                        Text("This Week")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 183, alignment: .leading)
                        //stats
                        Text("\(gameData?.currentFrequency ?? 1)/\(gameData?.totalFrequency ?? 1) units")
                            .font(.custom("Poppins-Regular", size: 18))
                            .frame(width: 183, alignment: .leading)
                    }
                    .padding(.leading, 20)
                }
            }
            
            Spacer()
            
            HStack { // Total Balance
                VStack {
                    Text("Total Balance")
                        .font(.custom("Poppins-Light", size: 12)) // poopins-light
                        // dollar amount
                    Text("100.00$")
                        .font(.custom("Poppins-Bold", size: 27))
                        .frame(width: 130, alignment: .leading)
                        // Profit amount
                }
                
                Image("chart-line")
                
                VStack {
                    ZStack {
                        Text("Initial Bet: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        Text("$100.00")
                            .font(.custom("Poppins-Regular", size: 18))
                            .padding(.leading, 60)
                            .frame(width: 130, alignment: .leading)
                    }
                    ZStack {
                        Text("Lost: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        Text("$5.00")
                            .font(.custom("Poppins-Regular", size: 18))
                            .frame(width: 130, alignment: .leading)
                            .padding(.leading, 25)
                    }
                    ZStack {
                        Text("Gained: ")
                            .font(.custom("Poppins-Bold", size: 18))
                            .frame(width: 210, alignment: .leading)
                        Text("$15.00")
                            .font(.custom("Poppins-Regular", size: 18))
                            .frame(width: 130, alignment: .leading)
                            .padding(.leading, 80)
                    }
                }
                .padding(.leading, 20)
                .frame(width: 212)
            }
            
            Spacer()
            NavBarView(viewIndex: 4)
                .padding(.bottom, -10)
        }
        //.frame(maxHeight: .infinity, alignment: .top)
        .frame(width: 350)
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.loadCurrentGame(userId: "8503f31c-8c1f-45eb-a7dd-180095aad816", gameCode: "NODqAbjW")
        }
    }
}

#Preview {
    GameCompletedView()
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
