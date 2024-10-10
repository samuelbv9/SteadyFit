//
//  LoginRegisterButton.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// This is a reusable button for login and register
// Use: LoginRegisterButton(title: "Text", background: .blue, action: viewModel.someFunc)

import SwiftUI

struct LoginRegisterButton: View {
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            // Action on press
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                    .frame(height: 50)
                Text(title)
                    .foregroundColor(Color.white)
            }
        }
    }
}

#Preview {
    LoginRegisterButton(title: "Value", background: .red, action: {})
}
