//
//  CreateGameView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 10/10/24.
//

import SwiftUI

class UserData: ObservableObject {
    @Published var selectedExerciseOption: String = "Choose an exercise"
    @Published var selectedFrequencyUnitOption: String = "unit"
    @Published var selectedDurationUnitOption: String = "unit"
    @Published var frequencyStr: String = ""
    @Published var frequencyInt: Int? = 0
    @Published var durationStr: String = ""
    @Published var durationInt: Int? = 0
    @Published var adaptiveGoalsChecked: Bool = false
    @Published var wagerStr: String = ""
    @Published var wagerInt: Int? = 0
    @Published var selectedFriends: [User] = []
}

struct CreateGameView: View {
    @StateObject var userData = UserData()
    
    let exerciseOptions = ["Choose an exercise", "Swimming", "Running/Walking", "Strength Training"]
    let timeUnits = ["unit", "day(s)", "week(s)", "month(s)"]

    var body: some View {
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
                    Text("Frequency:")
                    Spacer()
                    NumberInputField(inputText: $userData.frequencyStr, outputInt: $userData.frequencyInt)
                    Text("/")
                    DropdownPicker(selection: $userData.selectedFrequencyUnitOption, options: timeUnits)
                }
                HStack {
                    Text("Challenge Duration: ")
                    Spacer()
                    NumberInputField(inputText: $userData.durationStr, outputInt: $userData.durationInt).frame(width: 100)
                    DropdownPicker(selection: $userData.selectedDurationUnitOption, options: timeUnits)
                    
                }
                CheckboxView(isChecked: $userData.adaptiveGoalsChecked, checkboxText: "Enable Adaptive Goals")
            }
            .padding(.top, 20.0)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.deepBlue)
                Text("Next")
                    .foregroundColor(Color.white)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 3,
                   height: 80, alignment: .top)
            .ignoresSafeArea()
            NavBarView(viewIndex: 0)
        }
        .frame(width: 350)
        .ignoresSafeArea()
    }
}

struct CreateGameWagerView: View {
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
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.deepBlue)
                Text("Next")
                    .foregroundColor(Color.white)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 3,
                   height: 80, alignment: .top)
            .ignoresSafeArea()
            NavBarView(viewIndex: 0)
        }
        .frame(width: 350)
        .ignoresSafeArea()
    }
}
struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct CreateGameFriendsView: View {
    @ObservedObject var userData: UserData
//    @State private var selectedFriends: [User] = []
    let friendList: [User] = [
        User(name: "John S."),
        User(name: "Jane S."),
        User(name: "Mark. A"),
    ]
    var body: some View {
        VStack {
            HeaderView()
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("FRIENDS & VERIFICATION")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.gray)
                    Text("Create a Game")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }.padding(.bottom, 20)
                VStack(alignment: .leading){
                    Text("Add Friends")
                    MultiSelectDropdown(selectedItems: $userData.selectedFriends, items: friendList) { friend in
                        friend.name
                    }
                }
            }.padding(.top, 20)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.deepBlue)
                
                NavigationLink("Next", destination: CreateGameView())
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 3,
                   height: 80, alignment: .top)
            .ignoresSafeArea()
            NavBarView(viewIndex: 0)
        }
        .frame(width: 350)
        .ignoresSafeArea()
    }
}

#Preview {
    CreateGameFriendsView(userData: UserData())
}
