//
//  CreateGameView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 10/10/24.
//

import SwiftUI

struct CreateGameView: View {
    @State private var selectedExerciseOption = "Choose an exercise"
    @State private var selectedFrequencyUnitOption = "unit"
    @State private var selectedDurationUnitOption = "unit"
    @State private var frequencyStr: String = ""
    @State private var frequencyInt: Int? = nil
    @State private var durationStr: String = ""
    @State private var durationInt: Int? = nil
    @State private var adaptiveGoalsChecked: Bool = false
    
    let exerciseOptions = ["Choose an exercise", "Swimming", "Running/Walking", "Strength Training"]
    let timeUnits = ["unit", "day(s)", "week(s)", "month(s)"]

    var body: some View {
        VStack {
            HeaderView()
            VStack (alignment: .leading){
                VStack(alignment: .leading) {
                    Text("GOAL SETTING")
                        .font(.subheadline)
                    Text("Create a Game")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("Type of Exercise:")
                    Spacer()
                    DropdownPicker(selection: $selectedExerciseOption, options: exerciseOptions)
                }
                HStack {
                    Text("Frequency:")
                    Spacer()
                    NumberInputField(inputText: $frequencyStr, outputInt: $frequencyInt)
                    Text("/")
                    DropdownPicker(selection: $selectedFrequencyUnitOption, options: timeUnits)
                }
                HStack {
                    Text("Challenge Duration: ")
                    Spacer()
                    NumberInputField(inputText: $durationStr, outputInt: $durationInt).frame(width: 100)
                    DropdownPicker(selection: $selectedDurationUnitOption, options: timeUnits)
                    
                }
                CheckboxView(isChecked: $adaptiveGoalsChecked, checkboxText: "Enable Adaptive Goals")
            }
            .padding(.top, 10.0)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.steadyDarkBlue)
                    HStack() {
                        Text("Next")
                            .font(.custom("Poppins-Bold", size: 25))
                            .foregroundColor(Color.white)
                    }
            }
            .frame(width: UIScreen.main.bounds.width * 3,
                   height: 80)
            NavBarView()
        }
        .frame(width: 350)
        .ignoresSafeArea()
    }
}

#Preview {
    CreateGameView()
}
