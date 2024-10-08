//
//  ContentView.swift
//  SteadyFit
//
//  Created by Samuel Bechar on 10/7/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    var body: some View {
        if userIsLoggedIn {
            otherPage
        } else {
            content
        }
    }
    
    var otherPage: some View {
        VStack {
            Text("Logged In")
            Button {
                logout()
            } label: {
                Text("Log Out")
            }
        }
    }
    
    var content: some View {
        VStack {
            TextField("Email", text: $email)
            
            SecureField("Password", text: $password)
            
            Button {
                register()
            } label: {
                Text("Sign Up")
            }
            
            Button {
                login()
            } label: {
                Text("Already have an account? Login")
            }

        }
        .frame(width: 350)
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                // show some popup maybe?
                print(error!.localizedDescription)
            }
            else {
                userIsLoggedIn = true
            }
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                // show some popup maybe?
                print(error!.localizedDescription)
            }
            else {
                userIsLoggedIn = true
            }
            
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            userIsLoggedIn = false
        }
        catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
            
    }
}

#Preview {
    ContentView()
}
