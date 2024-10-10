//
//  LoginView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var userIsLoggedIn = false
    var body: some View {
        NavigationView {
            VStack {
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
            }
            .frame(width: 350)
        }
    }
    func login() {
        Auth.auth().signIn(withEmail: viewModel.email, password: viewModel.password) { result, error in
            if error != nil {
                // show some popup maybe?
                print(error!.localizedDescription)
            }
            else {
                // LOGIN
            }
        }
    }
}

#Preview {
    LoginView()
}
