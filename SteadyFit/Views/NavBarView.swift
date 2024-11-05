//
//  NavBarView.swift
//  SteadyFit
//
//  Created by Brenden Saur on 10/10/24.
//
//  This is a reusable View for the NavBar Footer

import SwiftUI

struct NavBarView: View {
    //@StateObject var viewModel = NavBarViewModel()
    let viewIndex: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(.steadyBlue)
            
            VStack {
                Spacer()
                
                HStack {
                    NavigationLink(destination: HomeView().navigationBarBackButtonHidden(true)) {
                        Image(viewIndex == 0 ? "calendar-weight-blue" : "calendar-weight-hd")
                            .resizable()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(viewIndex == 0 ? Color.white : Color.clear)
                            )
                            .padding(.bottom, 35)
                            .padding(.trailing, 30)
                            .frame(width: 70, height: 70)
                    }
                    
                    Image("vert-line")
                        .padding(.bottom, 35)
                    
                    Image(viewIndex == 1 ?
                          "plus-blue-hd" : "plus-hd")
                        .resizable()
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewIndex == 1 ? Color.white : Color.clear)
                        )
                        .padding(.bottom, 35)
                        .padding(.trailing, 20)
                        .padding(.leading, 20)
                        .frame(width: 80, height: 75)
                    
                    Image("vert-line")
                        .padding(.bottom, 35)
                    
                    NavigationLink(destination: ProfileView().navigationBarBackButtonHidden(true)) {
                        Image(viewIndex == 2 ? "user-hd-blue" : "user-hd")
                            .resizable()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(viewIndex == 2 ? Color.white : Color.clear)
                            )
                            .padding(.bottom, 35)
                            .padding(.leading, 30)
                            .frame(width: 70, height: 70)
                    }
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 3,
               height: 100, alignment: .bottom)
    }
}

#Preview {
    NavBarView(viewIndex: 0)
}
