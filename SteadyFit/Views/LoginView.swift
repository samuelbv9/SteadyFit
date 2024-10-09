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
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                
                SecureField("Password", text: $password)

                LoginRegisterButton(title: "Login", background: .red, action: login)
                    .padding()
                
                NavigationLink("Register", destination: RegisterView())
            }
            .frame(width: 350)
        }
    }
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
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
