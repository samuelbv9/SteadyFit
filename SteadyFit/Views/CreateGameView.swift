//
//  CreateGameView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 10/10/24.
//

import SwiftUI
import Combine

class UserData: ObservableObject {
    @Published var selectedExerciseOption: String = "Choose an exercise"
    @Published var frequencyStr: String = ""
    @Published var frequencyInt: Int? = nil
    @Published var durationStr: String = ""
    @Published var durationInt: Int? = nil
    @Published var distanceStr: String = ""
    @Published var distanceInt: Int? = nil
    @Published var adaptiveGoalsChecked: Bool = false
    @Published var wagerStr: String = ""
    @Published var wagerInt: Int? = 0
}
struct CreateGameView: View {
    @StateObject var userData = UserData()
    let exerciseOptions = ["Choose an exercise", "Swimming", "Running", "Walking", "Strength Training", "Cycling"]
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                VStack (alignment: .leading){
                    VStack(alignment: .leading) {
                        Text("GOAL SETTING")
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundColor(Color.gray)
                        Text("Create a Game")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }.padding(.bottom, 20)
                    HStack {
                        Text("Type of Exercise:")
                        Spacer()
                        DropdownPicker(selection: $userData.selectedExerciseOption, options: exerciseOptions)
                    }
                    HStack {
                        if userData.selectedExerciseOption == "Strength Training" {
                            VStack(alignment: .leading) {
                                   Text("Frequency:")
                                       .padding(.bottom, 2)
                                   HStack {
                                       NumberInputField(inputText: $userData.frequencyStr, outputInt: $userData.frequencyInt)
                                       Text("session(s) / week")
                                   }
                               }
                        }
                        else {
                            Text("Distance: ")
                            Spacer()
                            NumberInputField(inputText: $userData.distanceStr, outputInt: $userData.distanceInt)
                            Text("mile(s) / week")
                        }

                    }
                    HStack {
                        Text("Challenge Duration: ")
                        Spacer()
                        NumberInputField(inputText: $userData.durationStr, outputInt: $userData.durationInt).frame(width: 100)
                        Text("week(s)")
                    }
                    CheckboxView(isChecked: $userData.adaptiveGoalsChecked, checkboxText: "Enable Adaptive Goals")
                }
                .padding(.top, 20.0)
                Spacer()
                VStack(spacing: 0) {
                        NavigationLink(destination: CreateGameWagerView(userData: userData)) {
                            HStack() {
                                Text("Next")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .padding(20)
                            .frame(width: 400,
                                   height: 80)
                            .background(Color.deepBlue)
                        }
                    NavBarView(viewIndex: 1)
                }
            }
            .frame(width: 350)
            .ignoresSafeArea()
        }
       
    }
}

struct CreateGameWagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userData: UserData

    
    var body: some View {
        VStack {
            HeaderView()
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("WAGER AMOUNT")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.gray)
                    Text("Create a Game")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }.padding(.bottom, 20)
                VStack(alignment: .leading){
                    Text("Bet Size:")
                    NumberInputField(inputText: $userData.wagerStr, outputInt: $userData.wagerInt)
                }
            }.padding(.top, 20)
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
                        GamesStore.shared.postGame(userData)
                    }) {
                        HStack {
                            Text("Publish")
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
    }
}

#Preview {
//    CreateGameFriendsView(userData: UserData())
//    CreateGameView()
//    CreateGameFriendsView(userData: UserData())
}
