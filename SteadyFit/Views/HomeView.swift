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
    @ObservedObject var gamesStore = GamesStore.shared

    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                Text("Your Active Games")
                    .font(.custom("Poppins-Bold", size: 30))
                    .padding(.bottom, 20)
                ScrollView {
                    ForEach(gamesStore.activeGames, id: \.gameCode) { game in
                        VStack(alignment: .leading, spacing: 5) {
                            if game.exerciseType == "Strength Training" {
                                GameCard(exerciseType: game.exerciseType, goal: Double(game.frequencyGoal ?? 0), currentProgress: Double(game.frequency ?? 0), healthStore: viewModel.healthStore, gameCode: game.gameCode)
                            }
                            else {
                                GameCard(exerciseType: game.exerciseType, goal: (game.distanceGoal ?? 0), currentProgress: (game.distance ?? 0), healthStore: viewModel.healthStore, gameCode: game.gameCode)
                            }
                        }
                    }
                }
                Spacer()
                NavBarView(viewIndex: 0)
            }
            .frame(width: 350)
            .ignoresSafeArea()
            .onAppear {
                Task {
                     await GamesStore.shared.getActiveGames(userId: Auth.auth().currentUser?.uid ?? "0")
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .refreshable {
            await GamesStore.shared.getActiveGames(userId: Auth.auth().currentUser?.uid ?? "0")
        }
    }
    
}

#Preview {
    HomeView()
}
