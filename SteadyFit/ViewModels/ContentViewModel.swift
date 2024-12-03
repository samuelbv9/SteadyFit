//
//  ContentViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// THE TUTORIAL FOR THIS IS AT 1:10:00
// This is the View Model for ContentView

import Foundation
import FirebaseAuth

// Create an ObservableObject that is global
class ContentViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    @Published var isSurveyCompleted: Bool = false
    private var handler: AuthStateDidChangeListenerHandle?
    
    // Listen for changes in user and update if change occurs
    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }
    
    // Returns if a user is signed in or not
    // True if signed in
    // False if not signed in
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
