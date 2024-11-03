//
//  ActiveGameView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 11/1/24.
//

import SwiftUI

struct ActiveGameView: View {
    @StateObject private var viewModel = ActiveGameViewModel()
    var body: some View {
        VStack {
            HeaderView()
            Spacer()
            
            HStack { // Game title and back button
                Button {
                    // Action on press
                    // action()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .foregroundColor(Color.deepBlue)
                            .frame(height: 30)
                            .frame(width: 35)
                        Text("<")
                            .foregroundColor(Color.white)
                    }
                }
                Text("Game Title")
                .font(.custom("Poppins-Bold", size: 30))
                .kerning(-0.6) // Decreases letter spacing
            }
            //.padding(.top, -30)
            
            Spacer()
            
            VStack { // Your adaptive goal
                Text("Your Adaptive Goal")
                    .font(.custom("Poppins-Bold", size: 20))
                    .kerning(-0.6) // Decreases letter spacing
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.deepBlue, lineWidth: 2)
                        .frame(height: 150)
                        .frame(width:322)
                    VStack{
                        Text("Distance") // This will need to change based on game
                            .font(.custom("Poppins-Bold", size: 20))
                            .kerning(-0.3) // Decreases letter spacing
                        Text("Current Progress") // This will need to change based on game
                            .font(.custom("Poppins-Bold", size: 20))
                            .kerning(-0.3) // Decreases letter spacing
                        Button {
                            // Action on press
                            // action()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 0)
                                    .foregroundColor(Color.deepBlue)
                                    .frame(height: 50)
                                    .frame(width: 322)
                                    .clipShape(RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight]))
                                Text("Upload & Verify Workout")
                                    .foregroundColor(Color.white)
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
                Text("Profile Icons Here (clickable?)")
                    .font(.custom("Poppins-Bold", size: 20))
                    .kerning(-0.6) // Decreases letter spacing
            }
            
            Spacer()
            
            VStack { // Overall Stats
                Text("Overall Statistics")
                    .font(.custom("Poppins-Bold", size: 20))
                    .kerning(-0.6) // Decreases letter spacing
                HStack{
                    // Circle completion percent pie chart
                    VStack {
                        Text("Overall Completion")
                            .font(.custom("Poppins-Bold", size: 18))
                        //stats
                        Text("This Week")
                            .font(.custom("Poppins-Bold", size: 18))
                        //stats
                    }
                }
            }
            
            Spacer()
            
            HStack { // Total Balance
                VStack {
                    Text("Total Balance")
                        .font(.custom("Poppins-Bold", size: 12)) // poopins-light
                        // dollar amount
                    Text("100$")
                        .font(.custom("Poppins-Bold", size: 18))
                        // Profit amount
                }
                VStack {
                    Text("Initial Bet: ")
                        .font(.custom("Poppins-Bold", size: 18))
                    Text("Lost: ")
                        .font(.custom("Poppins-Bold", size: 18))
                    Text("Gain: ")
                        .font(.custom("Poppins-Bold", size: 18))
                }
            }
            
            Spacer()
            NavBarView(viewIndex: 4)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(width: 350)
        .ignoresSafeArea()
        .onAppear {
            viewModel.loadCurrentGame(userId: "1", gameCode: "1")
        }
    }
}

#Preview {
    ActiveGameView()
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
