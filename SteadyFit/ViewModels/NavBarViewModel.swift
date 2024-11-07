//
//  NavBarViewModel.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//
// This is the View Model for NavBarView

import Foundation
import FirebaseAuth

class NavBarViewModel: ObservableObject {
    @Published var currentViewIndex: Int = 0

    func updateViewIndex(to newIndex: Int) {
        currentViewIndex = newIndex
    }
}
