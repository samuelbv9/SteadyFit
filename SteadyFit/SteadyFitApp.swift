//
//  SteadyFitApp.swift
//  SteadyFit
//
//  Created by Samuel Bechar on 10/7/24.
//

import SwiftUI
import Firebase

@main
struct SteadyFitApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            TestingView()
            //CreateGameView()
        }
    }
}
