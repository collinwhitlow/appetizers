import SwiftUI

struct HistoryView: View {
    @ObservedObject var store = Backend.shared
    @State private var isPresenting = false

    var body: some View {
        NavigationView {
            List(store.chatts.indices, id: \.self) {
                ChattListRow(chatt: store.chatts[$0])
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
            }
            .listStyle(.plain)
            .refreshable {
                await store.getChatts()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Chatter")
                }
                ToolbarItem(placement:.navigationBarTrailing) {
                    Button(action: {
                        if ChatterID.shared.expiration == Date(timeIntervalSince1970: 0.0) { // upon first launch
                            ChatterID.shared.open()
                        }
                        isPresenting.toggle()
                    }) {
                        Image(systemName: "square.and.pencil")
                    }.sheet(isPresented: $isPresenting) {
                        PostView(isPresented: $isPresenting)
                    }
                }
            }
            .task {
                await store.getChatts()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
