import SwiftUI

struct HistoryView: View {
    @ObservedObject var store = Backend.shared
    @State private var searchText = ""
    
    var filteredIndicies: [Int]{
        if searchText.isEmpty {
            return Array(0..<store.history.count)
        } else {
            var temp : [Int] = []
            for i in 0..<store.history.count {
                if store.history[i].actorName!.localizedCaseInsensitiveContains(searchText) {
                    temp.append(i)
                }
            }
            return temp
        }
    }

    var body: some View {
        NavigationView {
            List(filteredIndicies.indices, id: \.self) { index in
                HistoryListRow(historyentry: store.history[filteredIndicies[index]])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color((index % 2 == 0) ? .systemGray5 : .systemGray6))
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search a name")
            .listStyle(.plain)
            .refreshable {
                await store.getHistory()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your History")
                }
            }
            .task {
                await store.getHistory()
            }
            .overlay(Group {
                if store.history.isEmpty {
                    Text("No History to Display")
                }
            })
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
