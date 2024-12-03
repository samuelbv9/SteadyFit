//
//  LoginViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// This is the View Model for LoginView
//
// TODOS:
// 1. Make a pop-up for incorrect password or email

import Foundation
import FirebaseAuth
import SwiftUICore

class LoginViewModel: ObservableObject {
    // Public vars
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoginSuccessful = false // Track registration success
  
//    init() {}
//    
//    var contentViewModel: ContentViewModel
//    init(contentViewModel: ContentViewModel) {
//        self.contentViewModel = contentViewModel
//    }

    // Logs in user using FirebaseAuth
    func login(){
        guard validate() else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                // show some popup maybe?
                print("FAILED LOGIN!")
                print(error!.localizedDescription)
            }
            else {
                // LOGIN
//                self.contentViewModel.isSurveyCompleted = true
                print("Signed in")
                // Set registration success
                  DispatchQueue.main.async {
                      self.isLoginSuccessful = true
                  }
            }
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
        
        return true
    }
}
