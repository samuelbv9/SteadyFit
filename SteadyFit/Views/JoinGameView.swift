//
//  JoinGameView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 10/26/24.
//

import SwiftUI

struct JoinGameView: View {
    var body: some View {
        NavigationView {
            VStack() {
                HeaderView()
                VStack(alignment: .leading) {
                    Text("Adding a New Game")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.bottom, 20)
                    NavigationLink(destination: JoinGamecode()) {
                        VStack(alignment: .leading) {
                            Text("Join a Game")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                            Spacer()
                            Text("Enter in a game code to start wagering with your friends!")
                                .foregroundColor(Color.white)
                        }
                        .padding(20)
                        .background(Color.deepBlue)
                        .frame(width: 350, height: 180)
                        .cornerRadius(15)
                    }

                
                    Text("or")
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    NavigationLink(destination: CreateGameView()) {
                        VStack(alignment: .leading) {
                            Text("Create a Game")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.deepBlue)
                            Spacer()
                            Text("Got an idea? Create a game and invite your friends!")
                                .foregroundColor(Color.deepBlue)
                        }
                        .padding(20)
                        .frame(width: 345, height: 180)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.deepBlue, lineWidth: 4)
                        )
                    }
                    
                }
                Spacer()
                NavBarView(viewIndex: 1)
            }
                .frame(width: 350)
                .ignoresSafeArea()
        }
    }
}


struct JoinGamecode: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userInputGameCode = ""
    @State private var userInputPassword = ""
    var body: some View {
        VStack() {
            HeaderView()
            VStack(alignment: .leading) {
                Text("Join Game")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)
                Text("Game Code")
                TextInputField(text: $userInputGameCode)
                    .padding(.bottom, 5)
                Text("Password (Optional)")
                TextInputField(text: $userInputPassword)
            }
            Spacer()
            VStack(spacing: 0) {
                HStack() {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding()
                        Text("Back")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        GamesStore.shared.joinGame(userInputGameCode, userInputPassword)
                    }) {
                        HStack {
                            Text("Join Game")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Image(systemName: "arrow.right")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                .padding(20)
                .frame(width: 400,
                       height: 80)
                .background(Color.deepBlue)
                NavBarView(viewIndex: 1)
            }
        }
            .frame(width: 350)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
    }
}


//#Preview {
//    JoinGamePreview()
//}
