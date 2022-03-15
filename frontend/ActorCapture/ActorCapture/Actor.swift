//
//  Actor.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/12/22.
//

import SwiftUI


// PLACEHOLDER - BUT DON'T CHANGE NAME
struct ActorView: View {
    @ObservedObject var store = Backend.shared
    @Binding var isPresented: Bool
    @State private var isPresenting = false

    var body: some View {
        NavigationView {
            List(store.history.indices, id: \.self) {
                HistoryListRow(historyentry: store.history[$0])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
            }
            .listStyle(.plain)
            .refreshable {
                await store.getHistory()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("HELLO")
                }
            }
            .task {
                await store.getHistory()
            }
        }
    }
}
