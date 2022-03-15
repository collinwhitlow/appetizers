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

    var body: some View {
        NavigationView {
            Text("You get to implement this View! actorname: " + actorName)
        }
    }
}
