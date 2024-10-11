//
//  LoginView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// This is the Login Screen

import Foundation
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                
                // Shows Error Message From viewModel
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                
                TextField("Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                LoginRegisterButton(title: "Login", background: .blue, action: viewModel.login)
                    .padding()
                
                NavigationLink("Register", destination: RegisterView())
                
                Spacer()
                NavBarView()
            }
            .frame(width: 350)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LoginView()
}
