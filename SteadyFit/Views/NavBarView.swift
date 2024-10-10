//
//  NavBarView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/10/24.
//

import SwiftUI

struct NavBarView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(.steadyBlue)
            
            VStack {
                Spacer()
                
                HStack {
                    Image("calendar-weight")
                        .padding(.bottom, 35)
                    
                    Image("vert-line")
                        .padding(.bottom, 35)
                    
                    Image("user-alt")
                        .padding(.bottom, 35)
                        .frame(width: 55, height: 55)
                    
                    Image("vert-line")
                        .padding(.bottom, 35)
                    
                    Image("home-icon")
                        .padding(.bottom, 35)
                        .frame(width: 55, height: 55)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 3,
               height: 100, alignment: .bottom)
    }
}

#Preview {
    NavBarView()
}
