import Foundation
import UIKit

final class Backend: ObservableObject  {
    static let shared = Backend() // create one instance of the class to be shared
    private init() {}                // and make the constructor private so no other
                                     // instances can be created
    @Published private(set) var history = [HistoryEntry]()
    @Published private(set) var watchlist = [WatchListEntry]()

    private let nFieldsHist = 5
    private let nFieldsWatch = Mirror(reflecting: WatchListEntry()).children.count

    private let serverUrl = "https://3.144.236.126/"

    @MainActor
    func getHistory() async {
        guard let apiUrl = URL(string: serverUrl+"gethistory/") else {
            print("gethistory: Bad URL")
            return
        }
        
        let jsonObj = ["userid": "test_1_user"]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("getHistory: jsonData serialization error")
            return
        }
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
                
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("gethistory: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
                
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("gethistory: failed JSON deserialization")
                return
            }
            let historyReceived = jsonObj["rows"] as? [[String?]] ?? []
            
            self.history = [HistoryEntry]()
            for historyentry in historyReceived {
                if historyentry.count == self.nFieldsHist {
                    self.history.append(HistoryEntry(actorName: historyentry[1],
                                                    imageUrl: historyentry[2],
                                                    confidence: historyentry[4]))
                } else {
                    print("getHistory: Received unexpected number of fields: \(historyentry.count) instead of \(self.nFieldsHist).")
                }
            }
        } catch {
            print("gethistory: NETWORKING ERROR")
        }
    }
    func deleteHistory(_ history: HistoryEntry) async {
        let jsonObj = ["userid": await UIDevice.current.identifierForVendor?.uuidString,
                       "actorName": history.actorName]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("deleteHistory: jsonData serialization error")
            return
        }
                
        guard let apiUrl = URL(string: serverUrl+"deletehistory/") else {
            print("deleteHistory: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "DELETE"
        request.httpBody = jsonData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("deleteHistory: HTTP STATUS: \(httpStatus.statusCode)")
                return
            } else {
                await getHistory()
            }
        } catch {
            print("deleteHistory: NETWORKING ERROR")
        }
    }
}
