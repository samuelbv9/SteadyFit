//
//  RegisterView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/9/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            
            SecureField("Password", text: $password)
            
            Button {
                //register()
            } label: {
                Text("Sign Up")
            }
            
            Button {
                //login()
            } label: {
                Text("Already have an account? Login")
            }
            
        }
        .frame(width: 350)
    }
}


#Preview {
    RegisterView()
}
