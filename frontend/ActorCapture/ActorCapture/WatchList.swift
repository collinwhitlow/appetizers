import SwiftUI

struct WatchListView: View {
    @ObservedObject var store = Backend.shared
    @State private var isPresenting = false

    var body: some View {
        NavigationView {
            List(store.watchlist.indices, id: \.self) {
                WatchListRow(watchlistentry: store.watchlist[$0])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
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
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView()
    }
}
