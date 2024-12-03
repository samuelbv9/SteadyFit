//
//  ProfileView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//
//  This is the Profile Screen

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var gamesStore = GamesStore.shared
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                
                Text("Your Past Games")
                    .font(.custom("Poppins-Bold", size: 30))
                    .padding(.bottom, 15)
                    .padding(.top, 10)
                ScrollView {
                    //PastGameCard(exerciseType: "Running", duration: 5, betSize: 100, gameCode: "123")
                    ForEach(gamesStore.pastGames, id: \.gameCode) { game in
                        VStack(alignment: .leading, spacing: 5) {
                            PastGameCard(
                                exerciseType: game.exerciseType,
                                duration: game.duration,
                                betSize: game.betAmount,
                                gameCode: game.gameCode
                            )
                        }
                    }
                }
                Spacer()
                
                LoginRegisterButton(title: "Logout", background: .deepBlue, action: viewModel.logout)
                NavigationLink("", destination: LaunchView(), isActive: $viewModel.isLoggedOut)
                      .hidden()
                
                Spacer()
                NavBarView(viewIndex: 2)
            }
            .frame(width: 350)
            .ignoresSafeArea()
            .onAppear {
                Task {
                    await GamesStore.shared.getPastGames(userId: Auth.auth().currentUser?.uid ?? "0")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
