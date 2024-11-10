//
//  ProfileViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//
//  This is the View Model for ProfileView

import Foundation
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var isLoggedOut = false
    func logout() {
        do {
            try Auth.auth().signOut()
            print("Signed Out")
            isLoggedOut = true
        }
        catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
}
