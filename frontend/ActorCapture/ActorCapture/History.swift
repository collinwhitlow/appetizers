import SwiftUI

struct HistoryView: View {
    @ObservedObject var store = Backend.shared
//    @State private var isPresenting = false

    var body: some View {
        NavigationView {
            List(store.history.indices, id: \.self) {
                HistoryListRow(historyentry: store.history[$0])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
            }
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
