//
//  ListRows.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/12/22.
//

import SwiftUI

struct HistoryListRow: View {
    var historyentry: HistoryEntry
    
    var body: some View {
        HStack {
            if let actorname = historyentry.actorName, let imageURL = historyentry.imageUrl {
                AsyncImage(url: URL(string: imageURL)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(maxWidth:430, maxHeight: 130, alignment: .leading)
                                    .padding()
                                    },
                            placeholder: {
                                ProgressView()
                            }
                )
                VStack {
                    Text(actorname)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                        .font(.system(size: 23, weight: .heavy, design: .default))
                    if let confidence = historyentry.confidence {
                        Text("Confidence: " + confidence).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    }
                }
                Spacer()
            }
        }
    }
}

struct WatchListRow: View {
    var watchlistentry: WatchListEntry

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let moviename = watchlistentry.movieName, let imageURL = watchlistentry.imageUrl {
                    Text(moviename).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text(imageURL).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
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
