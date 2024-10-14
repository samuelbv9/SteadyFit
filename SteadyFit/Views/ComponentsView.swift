//
//  ComponentsView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 10/11/24.
//

import SwiftUI

struct DropdownPicker: View {
    @Binding var selection: String
    let options: [String]
    var body: some View {
        Picker("Select an option", selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(option)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct NumberInputField: View {
    @Binding var inputText: String
    @Binding var outputInt: Int?
    var body: some View {
        TextField("Enter a number", text: $inputText)
            .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: inputText) { newValue in
                                                if let number = Int(newValue) {
                                                    outputInt = number
                                                } else {
                                                    outputInt = nil
                                                }
                                            }
    }
}

struct CheckboxView: View {
    @Binding var isChecked: Bool
    let checkboxText: String
    var body: some View {
        Toggle(isOn: $isChecked) {
            Text(checkboxText)
        }
        .toggleStyle(CheckboxToggleStyle()) // Custom style to make it look like a checkbox
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

//#Preview {
//    DropdownPicker()
//}
