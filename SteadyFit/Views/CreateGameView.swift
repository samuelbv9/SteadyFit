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
            /// HEADER
            Text("SteadyFit")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.5215686275, green: 0.7725490196, blue: 0.9529411765))

            Spacer().frame(height: 30)

            /// MAIN CONTENT
            VStack(alignment: .leading) {
                Text("GOAL SETTING")
                    .font(.subheadline)
                Text("Create a Game")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                /// TYPE OF EXERCISE
                HStack {
                    Text("Type of Exercise:")
                    Spacer()
                    Picker("Select an option", selection: $selectedExerciseOption) {
                        ForEach(exerciseOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                /// FREQUENCY OF EXERCISE
                HStack {
                    Text("Frequency:")
                    Spacer()
                    TextField("Enter an integer", text: $frequencyStr)
                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .onChange(of: frequencyStr) { newValue in
                                            if let number = Int(newValue) {
                                                frequencyInt = number
                                            } else {
                                                frequencyInt = nil
                                            }
                                        }
                    Spacer()
                    Text("/")
                    Spacer()
                    Picker("Select an option", selection: $selectedFrequencyUnitOption) {
                        ForEach(timeUnits, id: \.self) { option in
                            Text(option)
                        }
                    }
                }
                /// CHALLENGE DURATION
                HStack {
                    Text("Challenge Duration: ")
                    Spacer()
                    TextField("Enter an integer", text: $durationStr)
                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .onChange(of: durationStr) { newValue in
                                            if let number = Int(newValue) {
                                                durationInt = number
                                            } else {
                                                durationInt = nil
                                            }
                                        }
                    Spacer()
                    Picker("Select an option", selection: $selectedDurationUnitOption) {
                        ForEach(timeUnits, id: \.self) { option in
                            Text(option)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    CreateGameView()
}

// red: 133, 197, 243
