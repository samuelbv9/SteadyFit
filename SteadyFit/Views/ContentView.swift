//
//  ContentView.swift
//  SteadyFit
//
//  Created by Samuel Bechar on 10/7/24.
//
// Main Content View for SteadyFit
//
// TODOS:
// 1. Make home page and remove old otherPage code and logout()

import Foundation
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        if viewModel.isSignedIn {
            otherPage
        } else {
            LoginView()
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

#Preview {
    ContentView()
}
