//
//  RegisterViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// This is the View Model for RegisterView
//
// TODOS:
// 1. Show a pop-up for FirebaseAuth failure

import Foundation
import FirebaseAuth

class RegisterViewModel: ObservableObject {
    // Public vars
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    // Registers the user using FirebaseAuth
    func register() {
        guard validate() else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print("FAILED REGISTER!!")
                print(error!.localizedDescription)
            }
            guard let uid = result?.user.uid else {
                DispatchQueue.main.async {
                    print("Failed to retrieve user UID.")
                }
                return
            }
            
            // Successfully registered
            print("Registered with UID: \(uid)")
            
            //SEND UUID and username TO DB
            
        }
    }
    
    // Validates imput meets criteria
    private func validate() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Invalid Email"
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be 6 or more characters"
            return false
        }
        
        return true
    }
}
