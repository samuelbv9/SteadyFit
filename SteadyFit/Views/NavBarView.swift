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
                    Image("home-icon-hd")
                        .resizable()
                        .padding(.bottom, 35)
                        .padding(.trailing, 30)
                        .frame(width: 70, height: 70)
                    
                    Image("vert-line")
                        .padding(.bottom, 35)
                    
                    Image("calendar-weight-hd")
                        .resizable()
                        .padding(.bottom, 35)
                        .padding(.trailing, 20)
                        .padding(.leading, 20)
                        .frame(width: 70, height: 65)
                    
                    Image("vert-line")
                        .padding(.bottom, 35)
                    
                    Image("user-alt")
                        .resizable()
                        .padding(.bottom, 35)
                        .padding(.leading, 30)
                        .frame(width: 70, height: 70)
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
