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
    
    // 1.
    @State var isActive:Bool = false
    
    var body: some View {
        VStack {
            // 2.
            if self.isActive {
                // 3.
                MenuBottom()
            } else {
                // 4.
                Image(systemName: "person.crop.rectangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Rectangle())

                Text("ActorCapture")
                    .font(.title)
            }
        }
        .task {
            await store.getHistory()
            await store.getWatchlist()
        }
        // 5.
        .onAppear {
            // 6.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                // 7.
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

