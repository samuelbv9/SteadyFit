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
            self.sendUserDataToDatabase(uid: uid, email: self.email)
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
    
    // Sends the user's UID and email to API
    func sendUserDataToDatabase(uid: String, email: String) {
        // Define the API endpoint and request
        guard let url = URL(string: "https://52.200.16.208/create_user/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare JSON data
        let userData: [String: Any] = [
            "user_id": uid,
            "username": email
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            print("Failed to encode user data: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send user data to database: \(error.localizedDescription)")
            }
            
            // Check if there is data in the response
            guard let response = response else {
                print("No data received from the server.")
                return
            }
            
            print(response)
            
        }.resume()
    }

}
