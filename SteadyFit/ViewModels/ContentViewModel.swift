//
//  ContentViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// THE TUTORIAL FOR THIS IS AT 1:10:00

import Foundation
import FirebaseAuth

class ContentViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
        //return true
    }
}
