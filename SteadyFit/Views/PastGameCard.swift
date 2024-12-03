//
//  PastGameCard.swift
//  SteadyFit
//
//  Created by Brenden Saur on 12/2/24.
//

import SwiftUI

struct PastGameCard: View {
    let exerciseType: String
    let duration: Int
    let betSize: Double
    let gameCode: String
    
    var body: some View {
        NavigationLink(destination: GameCompletedView(gameCode: gameCode)
            .navigationBarBackButtonHidden(true)) {
                VStack {
                    Text(exerciseType)
                        .font(.custom("Poppins-SemiBold", size: 15))
                        .foregroundColor(Color.black)
                        .kerning(-0.6)
                    Text("Duration: \(duration) weeks")
                        .font(.custom("Poppins-Light", size: 10))
                        .foregroundColor(Color.black)
                    Text("Bet Size: $\(String(format: "%.2f", betSize))")
                        .font(.custom("Poppins-Light", size: 10))
                        .foregroundColor(Color.black)
                }
                .frame(width: 325, height: 119)
                .clipShape(.rect(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.deepBlue, lineWidth: 2)
                )
                
            }
    }
}

#Preview {
    PastGameCard(exerciseType: "Running", duration: 5, betSize: 100, gameCode: "1234")
}
