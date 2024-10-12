//
//  ProfileView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                
                LoginRegisterButton(title: "Logout", background: .deepBlue, action: viewModel.logout)
                
                Spacer()
                NavBarView(viewIndex: 2)
            }
            .frame(width: 350)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ProfileView()
}
