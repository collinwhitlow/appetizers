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
                    Text("HELLO")
                }
//                Button(action: {
//                    isPresenting.toggle()
//                }) {
//                    Image(systemName: "square.and.pencil")
//                }/*.sheet(isPresented: $isPresenting) {
//                    ActorView(isPresented: $isPresenting)
//                }*/
            }
            .task {
                await store.getHistory()
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
