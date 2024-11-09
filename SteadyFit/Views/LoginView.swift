//
//  LoginView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// This is the Login Screen
// TODO:
// 1. Add a forgot password button
// 2. Fix fonts
// 3. Fix spacing

import Foundation
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Spacer()
                
                // Shows Error Message From viewModel
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.offGrey, lineWidth: 2)
                        .frame(height: 519)
                        .frame(width: 324)
                    VStack {
                        Text("Log in")
                            .padding(.top, -50)
                            .font(.custom("Poppins-Bold", size: 25))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Email")
                            .font(.custom("Poppins-Regular", size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                                .frame(height: 59)
                                .frame(width: 279)
                            TextField("Enter your email", text: $viewModel.email)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .padding(.leading, 30)
                        }
                        
                        Text("Password")
                            .font(.custom("Poppins-Regular", size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 15)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                                .frame(height: 59)
                                .frame(width: 279)
                            SecureField("Enter your password", text: $viewModel.password)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .padding(.leading, 30)
                        }
                        
                        LoginRegisterButton(title: "Login", background: .deepBlue, action: viewModel.login)
                            .padding()
                        
                        HStack {
                            Text("Don't have an account? ")
                                .font(.custom("Poppins-Light", size: 12))
                            NavigationLink("Register", destination: RegisterView())
                                .font(.custom("Poppins-Bold", size: 12))
                                .foregroundColor(Color.steadyBlue)
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.leading, 30)
                }
                Spacer()
            }
            .frame(width: 350)
            .ignoresSafeArea()
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
}
