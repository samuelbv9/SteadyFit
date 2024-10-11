//
//  HeaderView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/10/24.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(.steadyBlue)
            
            VStack {
                Text("SteadyFit")
                    .font(.custom("Poppins-Bold", size: 25))
                    .foregroundColor(Color.white)
            }
            .padding(.top, 45)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 3,
               height: 120, alignment: .top)
        .ignoresSafeArea()
    }
}

#Preview {
    HeaderView()
}
