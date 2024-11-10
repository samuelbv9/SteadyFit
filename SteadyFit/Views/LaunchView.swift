//
//  LaunchView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 11/9/24.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.deepBlue, Color.deepBlue.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    Text("SteadyFit")
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    Text("Put money where your mouth is.")
                        .foregroundColor(Color.white)
                        .padding(.bottom, 80.0)
                    NavigationLink(destination: LoginView()) {
                                           Text("Login")
                                               .font(.headline)
                                               .foregroundColor(.white)
                                               .padding()
                                               .background(Color.deepBlue)
                                               .cornerRadius(10)
                                       }
                    NavigationLink(destination: RegisterView()) {
                                           Text("Sign up")
                                               .font(.headline)
                                               .foregroundColor(.white)
                                               .padding()
                                               .background(Color.deepBlue)
                                               .cornerRadius(10)
                                       }
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    LaunchView()
//}
