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
        VStack(alignment: .leading) {
            HStack {
                if let actorname = historyentry.actorName, let imageURL = historyentry.imageUrl, let confidence = historyentry.confidence {
                    Text(actorname).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text(imageURL).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text(confidence).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                }
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
