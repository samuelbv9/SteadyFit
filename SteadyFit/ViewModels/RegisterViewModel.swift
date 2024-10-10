//
//  RegisterViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//

import Foundation
import FirebaseAuth

class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    func register() {
        guard validate() else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                // show some popup maybe?
                print("FAILED REGISTER!!")
                print(error!.localizedDescription)
            }
            else {
                print("Registered")
            }
            
        }
    }
    
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
        
        return true
    }
}
