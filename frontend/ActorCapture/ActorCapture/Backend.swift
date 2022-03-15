import Foundation
import UIKit
import Alamofire
import SwiftUI

final class Backend: ObservableObject  {
    static let shared = Backend() // create one instance of the class to be shared
    private init() {}                // and make the constructor private so no other
                                     // instances can be created
    @Published private(set) var history = [HistoryEntry]()
    @Published private(set) var watchlist = [WatchListEntry]()
    @Published private var bounding_boxes: [[[Int]]]?

    private let nFieldsHist = 5
    private let nFieldsWatch = 2

    private let serverUrl = "https://3.144.236.126/"
    
    private let userid = "user_1"

    @MainActor
    func getHistory() async {
        guard let apiUrl = URL(string: serverUrl+"gethistory/") else {
            print("gethistory: Bad URL")
            return
        }
        
        let jsonObj = ["userid": userid]
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
        let jsonObj = ["userid": userid,
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
    
    
    @MainActor
    func getWatchlist() async {
        guard let apiUrl = URL(string: serverUrl+"getwatchlist/") else {
            print("getwatchlist: Bad URL")
            return
        }
        
        let jsonObj = ["userid": userid]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("getwatchlist: jsonData serialization error")
            return
        }
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
                
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getwatchlist: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
                
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getwatchlist: failed JSON deserialization")
                return
            }
            let watchlistReceived = jsonObj["watchlist"] as? [[String?]] ?? []
            
            self.watchlist = [WatchListEntry]()
            for watchlistentry in watchlistReceived {
                if watchlistentry.count == self.nFieldsWatch {
                    self.watchlist.append(WatchListEntry(imageUrl: watchlistentry[1],
                                                         movieName: watchlistentry[0]))
                } else {
                    print("getwatchlist: Received unexpected number of fields: \(watchlistentry.count) instead of \(self.nFieldsWatch).")
                }
            }
        } catch {
            print("getwatchlist: NETWORKING ERROR")
        }
    }
    
    @MainActor
    func findFaces(_ image: UIImage) {
        guard let apiUrl = URL(string: serverUrl+"findfaces/") else {
            print("findFaces: Bad URL")
            return
        }
        
        AF.upload(multipartFormData: { mpFD in
            if let id = self.userid.data(using: .utf8) {
                mpFD.append(id, withName: "userid")
            }
            if let jpegImage = image.jpegData(compressionQuality: 1) {
                mpFD.append(jpegImage, withName: "image", fileName: "actorImage", mimeType: "image/jpeg")
            }
        }, to: apiUrl, method: .post).response { response in
            switch (response.result) {
            case .success:
                guard let data = response.data, response.error == nil else {
                    print("findFaces: NETWORKING ERROR")
                    return
                }
                if let httpStatus = response.response, httpStatus.statusCode != 200 {
                    print("findFaces: HTTP STATUS: \(httpStatus.statusCode)")
                    print("RESPONSE!!!!", response.response)
                    return
                }
                
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                    print("findFaces: failed JSON deserialization")
                    return
                }
                let recBoundingBoxes = jsonObj["bounding_boxes"] as? [[[Int]]] ?? nil
                self.bounding_boxes = recBoundingBoxes
                
                print("Find Faces Returned Successfully!")
                print(jsonObj)
            case .failure:
                print("Find Faces Failed!")
           }
        }
    }
}
