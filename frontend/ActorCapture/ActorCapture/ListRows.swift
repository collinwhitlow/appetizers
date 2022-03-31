//
//  ListRows.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/12/22.
//

import SwiftUI

struct HistoryListRow: View {
    var historyentry: HistoryEntry
    @State private var isPresenting = false
    @ObservedObject var store = Backend.shared
    
    func correctLineLimit() -> Int {
        let wordcount = historyentry.actorName!.split(separator: " ")
        return wordcount.count > 1 ? 2 : 1
    }

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
                        .lineLimit(3)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.75)
                        .lineLimit(self.correctLineLimit())

                    if let confidence = historyentry.confidence {
                        Text("Confidence: " + confidence).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    }
                    HStack (spacing: 40) {
                        Button(action: { Task {
                            await store.deleteHistory(historyentry)
                        }}) {
                            Image(systemName: "trash")
                        }.buttonStyle(BorderlessButtonStyle())
                        Button(action: {
                            isPresenting.toggle()
                        }) {
                            Image(systemName: "info.circle")
                        }.sheet(isPresented: $isPresenting) {
                            ActorView(isPresented: $isPresenting, actorName: actorname, confidence: historyentry.confidence, actorUrl: historyentry.imageUrl!, history_or_capture: "history")
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
    }
}

struct WatchListRow: View {
    var watchlistentry: WatchListEntry
    @ObservedObject var store = Backend.shared

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
                    HStack (spacing: 40) {
                        Button(action: { Task {
                            await store.deleteWatchlist(watchlistentry)
                        }}) {
                            Image(systemName: "trash")
                        }.buttonStyle(BorderlessButtonStyle())
                    }

                }
            }
        }
    }
}

final class PlayerUIState: ObservableObject {
    @Published var recDisabled = false
    func disable_add() {
        recDisabled = true
    }
    func gette() -> Bool{
        return recDisabled
    }
    
}

struct movieInfoRow: View {
    var infoEntry: MoreInfoEntry
    @ObservedObject var store = Backend.shared
    @StateObject var playerUIState = PlayerUIState()
    var body: some View {
        HStack (spacing: 0){
            if let movieName = infoEntry.movieName, let imageURL = infoEntry.imageUrl, let role = infoEntry.characterName {
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
                    Text("as")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                    Text(role)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                    HStack (spacing: 40) {
                        Button(action: { Task {
                            playerUIState.disable_add()
                            await store.addWatchlist(infoEntry)
                        }}) {
                            Image(systemName: "plus.circle")
                        }.buttonStyle(BorderlessButtonStyle())
                            .disabled(playerUIState.gette() || store.movieNameSet?.contains(movieName) == true)
                    }

                }
            }
        }
    }
}

struct actorInfoRow: View {
    var actorName: String
    var infoEntry: MoreInfoEntry
    var confidence: String
    @State private var isPresenting = false
    var actorUrl: String
    var history_or_capture: String
    @ObservedObject var store = Backend.shared

    var body: some View {
        HStack (spacing: 0){
            if let actorname = actorName, let actorUrl = actorUrl {
                AsyncImage(url: URL(string: actorUrl)!,
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
                    if let confidence = confidence { // get confidence level
                        Text("Confidence: " + confidence).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    }
                    HStack (spacing: 40) {
                        
                        Button(action: {
                            isPresenting.toggle()
                        }) {
                            Image(systemName: "back")
                        }.sheet(isPresented: $isPresenting) {
                            // either history or capture
                            if(history_or_capture == "history"){
                                HistoryView()
                            }
                            else{
                                // CaptureView()
                            }
                            
                        }.buttonStyle(BorderlessButtonStyle())
                    }
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
