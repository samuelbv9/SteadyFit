//
//  ProfileViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
// This is the View Model for ProfileView

import Foundation
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    func logout() {
        do {
            try Auth.auth().signOut()
            print("Singed Out")
        }
        catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
}
