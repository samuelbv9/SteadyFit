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

struct TextInputField: View {
    @Binding var text: String

    var body: some View {
        TextField("Type here...", text: $text)
//            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .keyboardType(.default)
//            .padding(.horizontal, 20)
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
                // Prevents users from entering non numeric input
                inputText = newValue.filter { $0.isNumber }
                if let number = Int(inputText) {
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

struct MultiSelectDropdown<Item: Identifiable & Hashable>: View {
    @Binding var selectedItems: [Item]
    var items: [Item]
    var itemName: (Item) -> String

    @State private var isExpanded = false

    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selectedItems.isEmpty ? "Select Friends" : selectedItems.map { itemName($0) }.joined(separator: ", "))
                        .foregroundColor(selectedItems.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            if isExpanded {
                List {
                    ForEach(items) { item in
                        HStack {
                            Text(itemName(item))
                            Spacer()
                            if selectedItems.contains(where: { $0.id == item.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(for: item)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .cornerRadius(8)
                .shadow(radius: 5)
            }
        }
        .padding()
    }
    
    private func toggleSelection(for item: Item) {
        if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }
}
