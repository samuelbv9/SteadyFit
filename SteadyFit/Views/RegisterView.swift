//
//  RegisterView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//
// This is the Register Screen

import Foundation
import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
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
                        Text("Sign up")
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
                        
                        LoginRegisterButton(title: "Sign up", background: .deepBlue, action: viewModel.register)
                            .padding()
                        
                        HStack {
                            Text("Have an exisiting account? ")
                                .font(.custom("Poppins-Light", size: 12))
                            NavigationLink("Login", destination: LoginView())
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
        }.navigationBarBackButtonHidden(true)
    }
}


#Preview {
    RegisterView()
}
