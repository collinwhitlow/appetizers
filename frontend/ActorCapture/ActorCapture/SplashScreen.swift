//
//  SplashScreen.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/30/22.
//

import Foundation
import SwiftUI
import UIKit

struct SplashScreen: View {
    @ObservedObject var store = Backend.shared
    @State var isActive:Bool = false
    
    var body: some View {
        VStack {
            if self.isActive {
                MenuBottom()
            } else {
                Image("ImageForSplash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .frame(width: 80, height: 80)
                    //.clipped()
                
                Text("ActorCapture")
                    .font(.title)
                    .padding(.top, 75)
            }
        }
        .task {
            await store.getHistory()
            await store.getWatchlist()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

