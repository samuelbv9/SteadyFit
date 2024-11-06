//
//  TestingView.swift
//  SteadyFit
//
//  Created by Debbie Shih on 11/6/24.
//

import SwiftUI

struct TestingView: View {
    var body: some View {
        Text("Testing: bet_details...")
        Button(action: {
            GamesStore.shared.getBetBalances("GAME001")
        }) {
            HStack {
                Text("Test GET /bet_details/ ")
                    .fontWeight(.medium)
                Image(systemName: "arrow.right")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
            }
        }
    }
}

//#Preview {
//    TestingView()
//}
