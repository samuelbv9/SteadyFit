//
//  HomeView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//
//  This is the Home Screen

import SwiftUI
import FirebaseAuth
import Firebase

struct HomeView: View {
    @State private var action: Int? = 0
    @StateObject var viewModel = HomeViewModel()
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                
                GameCard(exerciseType: "Running", goal: 10, currentProgress: 8.75, healthStore: viewModel.healthStore)
                
                GeometryReader { geometry in
                    VStack {
                        VStack {
                            Text("Welcome")
                                .font(.custom("Poppins-Bold", size: 30))
                                .kerning(-0.6) // Decreases letter spacing
                            Text("Upcoming Tasks")
                                .font(.custom("Poppins-Bold", size: 20))
                                .kerning(-0.6) // Decreases letter spacing
                            // Add your ActiveGames view or content here
                            // Will have different view for the games being shown here
                            NavigationLink(destination: ActiveGameView()) {
                                Text("HERE")
                            }
                        }
                        .frame(height: geometry.size.height * 2 / 3)
                       // let game = GamesStore.shared.activeGames[0] ?? nil
//                        if game != nil{
//                            VStack {
//                                if game?.exerciseType == "Strength Training" {
//                                    GameCard(exerciseType: game.exerciseType, goal: Double(game.frequencyGoal ?? 0), currentProgress: Double(game.frequency ?? 0), healthStore: viewModel.healthStore)
//                                }
//                                else {
//                                    GameCard(exerciseType: game.exerciseType, goal: (game.distanceGoal ?? 0), currentProgress: (game.distance ?? 0), healthStore: viewModel.healthStore)
//                                }
//                            }
//                        }
                    }
                }
                
                Spacer()
                NavBarView(viewIndex: 0)
            }
            .frame(width: 350)
            .ignoresSafeArea()
            .onAppear {
                Task {
                    await GamesStore.shared.getActiveGames(userId: "8503f31c-8c1f-45eb-a7dd-180095aad816")
                    // await GamesStore.shared.getActiveGames(userId: Auth.auth().currentUser?.uid ?? "0")
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
