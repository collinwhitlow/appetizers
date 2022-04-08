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
    @ObservedObject var store = Backend.shared
    
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                WatchListView()
                    .tabItem {
                        Image(systemName: "list.and.film")
                        Text("Watchlist")
                }.tag(1)
                CaptureView()
                    .tabItem {
                        Image(systemName: "camera.fill")
                        Text("Capture")
                }.tag(2)
                HistoryView()
                    .tabItem {
                        Image(systemName: "bookmark.square.fill")
                        Text("History")
                }.tag(3)
            }
            .navigationTitle("ActorCapture")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}
