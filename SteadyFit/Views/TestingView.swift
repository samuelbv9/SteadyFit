//
//  TestingView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 11/6/24.
//

import SwiftUI

struct TestingView: View {
    // Observe the shared instance of GamesStore
        @ObservedObject var gamesStore = GamesStore.shared
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding()
                Text("Upcoming Tasks")
                // ForEach loop to display each game's details
                List(gamesStore.activeGames, id: \.gameCode) { game in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Game Code: \(game.gameCode)")
                        Text("Exercise Type: \(game.exerciseType)")
                        Text("Bet Amount: \(game.betAmount)")
                        Text("Frequency: \(game.frequency ?? 0)")
                        Text("Distance: \(game.distance ?? 0.0)")
                        Text("Frequency Goal: \(game.frequencyGoal ?? 0)")
                        Text("Distance Goal: \(game.distanceGoal ?? 0.0)")
                        Text("Duration: \(game.duration)")
                        Text("Start Date: \(game.startDate)")
                    }
                    .padding()
                }
            }
            .padding()
            .onAppear {
                Task {
                    // Replace with the actual userId
                    await gamesStore.getActiveGames(userId: "766a6bf7-c4f2-4bfb-abb4-b9aa63f435e8")
                }
            }
        }
}

//#Preview {
//    TestingView()
//}
