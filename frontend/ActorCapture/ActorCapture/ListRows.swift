//
//  ListRows.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/12/22.
//

import SwiftUI

struct HistoryListRow: View {
    var historyentry: HistoryEntry
//    @Binding var isPresented: Bool
    
    var body: some View {
        HStack (spacing: 0){
            if let actorname = historyentry.actorName, let imageURL = historyentry.imageUrl {
                AsyncImage(url: URL(string: imageURL)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(maxWidth:300, maxHeight: 130, alignment: .leading)
                                    .padding()
                                    },
                            placeholder: {
                                ProgressView()
                            }
                ).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                VStack (spacing: 1){
                    Text(actorname)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                    if let confidence = historyentry.confidence {
                        Text("Confidence: " + confidence).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    }
                }
                Button(action: {
//                  isPresenting.toggle()
                }) {
                    Image(systemName: "info.circle")
                }/*.sheet(isPresented: $isPresenting) {
                    ActorView()
                }*/
            }
        }
    }
}

struct WatchListRow: View {
    var watchlistentry: WatchListEntry
    
    var body: some View {
        HStack (spacing: 0){
            if let movieName = watchlistentry.movieName, let imageURL = watchlistentry.imageUrl {
                AsyncImage(url: URL(string: imageURL)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                    .frame(maxWidth:300, maxHeight: 130, alignment: .leading)
                                    .padding()
                                    },
                            placeholder: {
                                ProgressView()
                            }
                ).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                VStack (spacing: 1){
                    Text(movieName)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                }
            }
        }
    }
}

//struct HistoryEntry {
//    var actorName: String?
//    @ChattPropWrapper var imageUrl: String?
//}
//
//struct WatchListEntry {
//    @ChattPropWrapper var imageUrl: String?
//    var movieName: String?
//}
