//
//  RegisterView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                LoginRegisterButton(title: "Sign Up", background: .green, action: viewModel.register)
                    .padding()
                
                NavigationLink("Already have an account? Log in", destination: LoginView())
                
            }
            .frame(width: 350)
        }
    }
}


#Preview {
    RegisterView()
}
