//
//  LoadingView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 11/9/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
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
                    }
                    .padding(20)
            }
        }
    }
}

#Preview {
    LoadingView()
}
