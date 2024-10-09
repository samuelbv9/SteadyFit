//
//  LoginRegisterButton.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//

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
                    .foregroundColor(Color.blue)
                    .frame(height: 50)
                Text(title)
            }
        }
    }
}

#Preview {
    LoginRegisterButton(title: "Value", background: .red, action: {})
}
