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
        VStack(spacing: 10){
            VStack (spacing: 8){
                VStack (spacing: 10){
                    if let actorname = actorName {
                        Text(actorname)
                            .frame(alignment: .center)
                            .font(.system(size: 19, weight: .heavy, design: .default))
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                        if let confidence = confidence { // get confidence level
                            Text("Confidence: " + confidence + "%").padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 16))
                        }
                    }
                }
                if let actorUrl = actorUrl {
                    AsyncImage(url: URL(string: actorUrl)!,
                               content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Circle())
                                        .frame(maxWidth:300, maxHeight: 130, alignment: .center)
                                        
                                        },
                                placeholder: {
                                    ProgressView()
                                }
                    ).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 150, alignment: .topLeading)
                }
                // Link(destination: URL(string: "https://www.imdb.com/name/" + actorID + "/")!) {
                // store.actorid[0].actorID
                Link(destination: URL(string: store.actorid.actorID ?? "https://www.imdb.com")!) {
                    Image(systemName: "link.circle.fill")
                        .font(.largeTitle)
                }
            }
            List(store.actorinfo.indices, id: \.self) {
                movieInfoRow(infoEntry: store.actorinfo[$0])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
                
            }.overlay(Group {
                if store.actorinfo.isEmpty {
                placeholder: do {
                    ProgressView()
                }
                }
            
            })
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .frame(alignment: .center)
            

            .task {
                await store.getactorinfo(actorName: actorName)
            }
            .refreshable {
                await store.getactorinfo(actorName: actorName)
            }
            
        }
    }
}
