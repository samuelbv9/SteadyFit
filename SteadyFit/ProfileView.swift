//
//  ProfileView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//
//  This is the Profile Screen

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var gamesStore = GamesStore.shared
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                
                if let firstGame = gamesStore.activeGames.first {
                    NavigationLink(destination: GameCompletedView(gameCode: firstGame.gameCode)) {
                        Text("Previous Game")
                    }
                } else {
                    Text("No Previous Game Available")
                }
                
                LoginRegisterButton(title: "Logout", background: .deepBlue, action: viewModel.logout)
                //NavigationLink("", destination: LaunchView(), isActive: $viewModel.isLoggedOut)
                 //     .hidden()
                
                Spacer()
                NavBarView(viewIndex: 2)
            }
            .frame(width: 350)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ProfileView()
}
