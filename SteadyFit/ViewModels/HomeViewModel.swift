//
//  HomeViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//
// This is the View Model for HomeView

import Foundation
import FirebaseAuth

class HomeViewModel: ObservableObject {
    // Tings here
    
    //initialize instance of class HealthStore
    var healthStore: HealthStore?
    
    init() {
        healthStore = HealthStore()
    }
}
