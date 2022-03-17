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
    var actorName: String
    var confidence: String?
    var actorUrl: String
    var history_or_capture: String
    var body: some View {
        NavigationView {
            List(0..<1) {
                actorInfoRow(actorName: actorName, infoEntry: store.actorinfo[$0], confidence: confidence!, actorUrl: actorUrl, history_or_capture: history_or_capture)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
            }
            List(store.actorinfo.indices, id: \.self) {
                movieInfoRow(infoEntry: store.actorinfo[$0])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)

            .task {
                await store.getactorinfo(actorName: actorName)
            }
        }
    }
    
    
    //struct ActorView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        ActorView(isPresented: false, actorID: "nm0000664", actorName: "Morgan Freeman")
    //    }
    //}
}
