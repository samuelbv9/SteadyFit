//
//  LoadingView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 11/9/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @Environment(\.presentationMode) var presentationMode // Environment variable to control navigation

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(alignment: .center) {
                Text("Verifying Task ")
                    .bold()
                    .font(.title)
                    .tracking(-1)
                Text("with Apple Health...")
                    .font(.title)
                    .tracking(-1)
                Circle()
                    .trim(from: 0.2, to: 1)
                    .stroke(Color.deepBlue, lineWidth: 8)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                        
                        // Dismiss view after 2-3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoadingView()
}
