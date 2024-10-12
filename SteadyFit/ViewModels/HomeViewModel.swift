//
//  HomeViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//
// This is the View Model for ContentView

import Foundation
import FirebaseAuth

class HomeViewModel: ObservableObject {
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
