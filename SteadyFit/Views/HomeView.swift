//
//  HomeView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/11/24.
//

import SwiftUI

struct HomeView: View {
    @State private var action: Int? = 0
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                
                GeometryReader { geometry in
                    VStack {
                        VStack {
                            Text("Active Games")
                                .font(.custom("Poppins-Bold", size: 30))
                                .kerning(-0.6) // Decreases letter spacing
                            
                            // Add your ActiveGames view or content here
                            // Will have different view for the games being shown here
                        }
                        .frame(height: geometry.size.height * 2 / 3)
        
                                                
                        
                        VStack{
                            Rectangle()
                                .fill(Color.deepBlue)
                                .frame(height: 2)
                            
                            Spacer()
                            
                            // This will change to the Join a game button
                            LoginRegisterButton(title: "Logout", background: .deepBlue, action: viewModel.logout)
                                .padding(.bottom, 10)
                            
                            
                            
                            Button(action: {
                                // Action can be left empty if navigation is the only purpose
                            }) {
                                NavigationLink(destination: CreateGameView()) {
                                    HStack {
                                        Text("Create Game")
                                            .foregroundColor(.deepBlue)
                                            .font(.custom("Poppins-SemiBold", size: 15))
                                            .kerning(-0.3) // Decreases letter spacing
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.deepBlue)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.deepBlue, lineWidth: 2)
                                    )
                                }
                            }
                            
                            Spacer()
                            
                        }
                        .frame(height: geometry.size.height * 1 / 3)
                    }
                }
                
                Spacer()
                NavBarView(viewIndex: 0)
            }
            .frame(width: 350)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    HomeView()
}
