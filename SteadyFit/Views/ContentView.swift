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
            HomeView()
        } else {
            LaunchView()
            //LoginView()
        }
    }
            
}

#Preview {
    ContentView()
}
