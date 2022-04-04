import SwiftUI

struct WatchListView: View {
    @ObservedObject var store = Backend.shared
    @State private var isPresenting = false
    @State private var searchText = ""
    
    var filteredIndicies: [Int]{
        if searchText.isEmpty {
            return Array(0..<store.watchlist.count)
        } else {
            var temp : [Int] = []
            for i in 0..<store.watchlist.count {
                if store.watchlist[i].movieName!.localizedCaseInsensitiveContains(searchText) {
                    temp.append(i)
                }
            }
            return temp
        }
    }

    var body: some View {
        NavigationView {
            List(filteredIndicies.indices, id: \.self) { index in
                WatchListRow(watchlistentry: store.watchlist[filteredIndicies[index]])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color((index % 2 == 0) ? .systemGray5 : .systemGray6))
            }
            .listStyle(.plain)
            .refreshable {
                await store.getWatchlist()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Watchlist")
                }
            }
            .task {
                await store.getWatchlist()
            }
            .overlay(Group {
                if store.watchlist.isEmpty {
                    Text("Watchlist Currently Empty")
                }
            })
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search A Show")
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView()
    }
}
