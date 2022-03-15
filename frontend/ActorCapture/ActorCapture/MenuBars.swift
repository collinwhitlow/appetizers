//
//  MenuBars.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/12/22.
//

import SwiftUI
import UIKit

struct MenuBottom: View {
    @State var selection = 2
    
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
//                Text("WatchList Tab")
                WatchListView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Watchlist")
                }.tag(1)
                CaptureView()
                    .tabItem {
                        Image(systemName: "camera.fill")
                        Text("Capture")
                }.tag(2)
//                Text("History Tab")
                HistoryView()
                    .tabItem {
                        Image(systemName: "mappin.circle.fill")
                        Text("History")
                }.tag(3)
            }
            .navigationTitle("ActorCapture")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}
