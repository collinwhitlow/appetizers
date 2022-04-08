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
                                    .frame(width: 100, height: 100, alignment: .leading)
                                    },
                            placeholder: {
                                ProgressView()
                            }
                ).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                VStack (spacing: 10){
                    Text(actorname)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.75)
                        .lineLimit(self.correctLineLimit())

                    if let confidence = historyentry.confidence {
                        Text("Confidence: " + confidence + "%").padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    }
                    HStack (spacing: 20) {
                        Button(action: { Task {
                            await store.deleteHistory(historyentry)
                        }}) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.body)
                                Text("Delete")
                                    .fontWeight(.semibold)
                                    .font(.body)
                            }
                            .padding(10)
                            .foregroundColor(.black)
                            .background(Color.red)
                            .cornerRadius(15)
                        }.buttonStyle(BorderlessButtonStyle())
                        Button(action: {
                            isPresenting.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.body)
                                Text("Info")
                                    .fontWeight(.semibold)
                                    .font(.body)
                            }
                            .padding(10)
                            .foregroundColor(.black)
                            .background(Color.green)
                            .cornerRadius(15)
                        }.sheet(isPresented: $isPresenting) {
                            ActorView(isPresented: $isPresenting, actorName: actorname, confidence: historyentry.confidence, actorUrl: historyentry.imageUrl!,  history_or_capture: "history")
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }.frame(width: UIScreen.main.bounds.size.width - 150, alignment: .center)
            }
        }.padding(.top, 10).padding(.bottom, 10)
    }
}

struct WatchListRow: View {
    var watchlistentry: WatchListEntry
    @ObservedObject var store = Backend.shared
    func correctLineLimit() -> Int {
        let wordcount = watchlistentry.movieName!.split(separator: " ")
        return wordcount.count > 1 ? 2 : 1
    }
    var body: some View {
        HStack (spacing: 0){
            if let movieName = watchlistentry.movieName, let imageURL = watchlistentry.imageUrl {
                AsyncImage(url: URL(string: imageURL)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                    .frame(width:90, height: 160, alignment: .leading)
                                    .padding()
                                    },
                            placeholder: {
                                ProgressView()
                            }
                ).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                VStack (spacing: 10){
                    Text(movieName)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.75)
                    HStack (spacing: 40) {
                        Button(action: { Task {
                            await store.deleteWatchlist(watchlistentry)
                        }}) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.body)
                                Text("Delete")
                                    .fontWeight(.semibold)
                                    .font(.body)
                            }
                            .padding(10)
                            .foregroundColor(.black)
                            .background(Color.red)
                            .cornerRadius(15)
                        }.buttonStyle(BorderlessButtonStyle())
                    }

                }.frame(width: UIScreen.main.bounds.size.width - 150, alignment: .center)
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
        HStack (alignment: .center, spacing: 0){
            if let movieName = infoEntry.movieName,let imageURL = "https://user-images.githubusercontent.com/24848110/33519396-7e56363c-d79d-11e7-969b-09782f5ccbab.png", let role = infoEntry.characterName {
                
                AsyncImage(url: URL(string: imageURL)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                    .frame(width: 90, height: 160, alignment: .leading)
                                    .padding()
                                    },
                            placeholder: {
                                ProgressView()
                            }
                ).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                
                VStack (spacing: 1){
                    Spacer()
                    Text(movieName)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.75)
                    Text(role)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .heavy, design: .default).italic())
                        .allowsTightening(true)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    HStack (spacing: 40) {
                        Button(action: { Task {
                            playerUIState.disable_add()
                            await store.addWatchlist(infoEntry)
                        }}) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .font(.body)
                                    .foregroundColor(Color.black)
                                Text("Watchlist")
                                    .fontWeight(.semibold)
                                    .font(.body)
                                    .foregroundColor(Color.black)
                            }
                            .padding(10)
                            .background(playerUIState.gette() || store.movieNameSet?.contains(movieName) == true ? Color.gray : Color.green)
                            .cornerRadius(15)
                        }.buttonStyle(BorderlessButtonStyle())
                            .disabled(playerUIState.gette() || store.movieNameSet?.contains(movieName) == true)
                    }
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width - 150, alignment: .center)
            }
        }
    }
}

struct movieInfoRow2: View {
    var infoEntry2: MoreInfoKnownfor
    @ObservedObject var store = Backend.shared
    @StateObject var playerUIState = PlayerUIState()
    var body: some View {
        HStack (alignment: .center, spacing: 0){
        
            if let movieName = infoEntry2.movieName, let imageURL = infoEntry2.imageUrl, let role = infoEntry2.characterName {
                
                AsyncImage(url: URL(string: imageURL)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                    .frame(width: 90, height: 160, alignment: .leading)
                                    .padding()
                                    },
                            placeholder: {
                                ProgressView()
                            }
                ).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                
                VStack (spacing: 1){
                    Spacer()
                    Text(movieName)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 21, weight: .heavy, design: .default))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.75)
                    Text(role)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .heavy, design: .default).italic())
                        .allowsTightening(true)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    HStack (spacing: 40) {
                        Button(action: { Task {
                            playerUIState.disable_add()
                            await store.addWatchlist(MoreInfoEntry(imageUrl: infoEntry2.imageUrl, characterName: infoEntry2.characterName, movieName: infoEntry2.movieName))
                        }}) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .font(.body)
                                    .foregroundColor(Color.black)
                                Text("Watchlist")
                                    .fontWeight(.semibold)
                                    .font(.body)
                                    .foregroundColor(Color.black)
                            }
                            .padding(10)
                            .background(playerUIState.gette() || store.movieNameSet?.contains(movieName) == true ? Color.gray : Color.green)
                            .cornerRadius(15)
                        }.buttonStyle(BorderlessButtonStyle())
                            .disabled(playerUIState.gette() || store.movieNameSet?.contains(movieName) == true)
                    }
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width - 150, alignment: .center)
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

                            
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
    }
}
