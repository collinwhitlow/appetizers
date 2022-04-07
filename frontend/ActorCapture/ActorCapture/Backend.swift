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
    @Published private(set) var actorinfo = [MoreInfoEntry]()
    @Published private(set) var actorinfo2 = [MoreInfoKnownfor]()
    @Published private(set) var actorid = ActorID()
    @Published private(set) var movieNameSet : Set<String>?
    
    @Published private(set) var bounding_boxes: [[[Int]]]?
    @Published private(set) var bounding_boxes_indices: [Int] = []
    @Published private(set) var waiting_for_find_faces = false
    @Published private(set) var scalingFactor: CGFloat = 0
    @Published private(set) var resultPage = ResultPage()
    @Published private(set) var waiting_for_find_actor = false
    @Published private(set) var box_index = -1
    
    @Published public var found_actor = false
    @Published public var cant_find_actor = false
    @Published public var cant_find_faces = false

    private let nFieldsHist = 6
    private let nFieldsWatch = 3

    private let serverUrl = "https://3.144.236.126/"
    
    private let userid = UIDevice.current.identifierForVendor?.uuidString
    
    func setHistory(_ hist: [HistoryEntry]) {
        history = hist
    }
    
    func addWatchlist(_ moreInfo: MoreInfoEntry) async {
        guard let apiUrl = URL(string: serverUrl+"postwatchlist/") else {
            print("postwatchlist: Bad URL")
            return
        }
        print(moreInfo)
        let jsonObj = ["userid": userid, "movietitle": moreInfo.movieName, "imageURL" : "", ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postwatchlist: jsonData serialization error")
            return
        }
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("postwatchlist: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            self.movieNameSet?.insert(moreInfo.movieName!)
        } catch {
            print("postwatchlist: NETWORKING ERROR")
        }
    }
    
    @MainActor
    func getactorinfo(actorName: String) async {
        
        guard let apiUrl = URL(string: serverUrl+"getactorinfo/") else {
            print("getactorinfo: Bad URL")
            return
        }
        
        let jsonObj = ["actorName": actorName]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("getactorinfo: jsonData serialization error")
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
                
            guard let data2 = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("gethistory: failed JSON deserialization")
                return
            }
             
            self.actorinfo = [MoreInfoEntry]()
            self.actorinfo2 = [MoreInfoKnownfor]()
            self.actorid = ActorID()
            let tem_p = "https://www.imdb.com/name/"
            let actorName = data2["actorID"]! as! String
            let mimo = tem_p + actorName  + "/"
            
            self.actorid = (ActorID(actorID: mimo))
            if let whole_dict = data2["cast_movies"] as? [[String:String]] {
                for dict in whole_dict{
                    //dict["image"]!
                    self.actorinfo.append(MoreInfoEntry(imageUrl: actorName, characterName: dict["description"],movieName: dict["title"]))
                    
                }
            }else{
                print("getactorinfo failed 1")
            }
            if let whole_dict2 = data2["known_for"] as? [[String:String]] {
                for dict2 in whole_dict2{
                    //dict["image"]!
                    self.actorinfo2.append(MoreInfoKnownfor(imageUrl: dict2["image"]!, characterName: dict2["role"],movieName: dict2["fullTitle"]))
                }
            }else{
                print("getactorinfo failed 2")
            }
        } catch {
            print("getactorinfo: NETWORKING ERROR")
        }
    }
    
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
                                                    confidence: historyentry[4],
                                                    uid: historyentry[5]))
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
                       "uid": history.uid]
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
    
    func deleteWatchlist(_ watchlist: WatchListEntry) async {
        let jsonObj = ["userid": userid,
                       "uid": watchlist.uid]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("deleteWatchlist: jsonData serialization error")
            return
        }
                
        guard let apiUrl = URL(string: serverUrl+"deletewatchlist/") else {
            print("deleteWatchlist: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "DELETE"
        request.httpBody = jsonData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("deleteWatchlist: HTTP STATUS: \(httpStatus.statusCode)")
                return
            } else {
                await getWatchlist()
            }
        } catch {
            print("deleteWatchlist: NETWORKING ERROR")
        }
    }
    
    
    @MainActor
    func getWatchlist() async {
        self.movieNameSet = []
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
                                                         movieName: watchlistentry[0],
                                                         uid: watchlistentry[2]))
                    self.movieNameSet?.insert(watchlistentry[0]!)
                } else {
                    print("getwatchlist: Received unexpected number of fields: \(watchlistentry.count) instead of \(self.nFieldsWatch).")
                }
            }
        } catch {
            print("getwatchlist: NETWORKING ERROR")
        }
    }
    
    func reset_capture() {
        self.bounding_boxes = nil
        self.bounding_boxes_indices = []
        self.scalingFactor = 0
        self.found_actor = false
        self.box_index = -1
    }

    func set_waiting_for_find_faces(_ b: Bool) {
        self.waiting_for_find_faces = b
    }
    
    func set_waiting_for_find_actor(_ b: Bool) {
        self.waiting_for_find_actor = b
    }
    
    func set_found_actor(_ b: Bool) {
        self.found_actor = b
    }
    
    @MainActor
    func findFaces(_ image: UIImage) {
        guard let apiUrl = URL(string: serverUrl+"findfaces/") else {
            print("findFaces: Bad URL")
            self.cant_find_faces = true
            return
        }
        
        AF.upload(multipartFormData: { mpFD in
            if let id = self.userid?.data(using: .utf8) {
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
                    return
                }
                
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                    print("findFaces: failed JSON deserialization")
                    return
                }
                let recBoundingBoxes = jsonObj["bounding_boxes"]! as? [[[Int]]] ?? nil
                if recBoundingBoxes == []{
                    print("alan has swine flu")
                    self.waiting_for_find_faces = false
                    self.reset_capture()
                    self.cant_find_faces = true
                    return
                }
                let temp_boxes = NSMutableArray(array: recBoundingBoxes!)
                let boxes = temp_boxes as NSArray as? [[[Int]]]
                
                var new_array: [[[Int]]] = []
                
                if image.size.height == image.size.width {
                    self.scalingFactor = CGFloat(300)/CGFloat(image.size.height)
                }
                else if image.size.height < image.size.width {
                    self.scalingFactor = CGFloat(300)/CGFloat(image.size.height)
                } else {
                    self.scalingFactor = CGFloat(300)/CGFloat(image.size.width)
                }
                
                for var box in boxes! {
                    let top_left = box[0]
                    let bottom_right = box[2]
                    
                    let x_center = (bottom_right[0] + top_left[0])/2
                    let y_center = (top_left[1] + bottom_right[1])/2
                    
                    box.append([x_center, y_center])
                    
                    new_array.append(box)
                }
                
                for i in 0...(new_array.count-1) {
                    self.bounding_boxes_indices.append(i)
                }
                self.bounding_boxes = new_array
                self.waiting_for_find_faces = false
                self.cant_find_faces = false
                
                print("Find Faces Returned Successfully!")
            case .failure:
                self.cant_find_faces = true
                print("Find Faces Failed!")
           }
        }
    }
    
    @MainActor
    func findActor(_ image: UIImage, _ box_index: Int) {
        guard let apiUrl = URL(string: serverUrl+"findactor/") else {
            print("findActor: Bad URL")
            self.cant_find_actor = true
            return
        }
        
        AF.upload(multipartFormData: { mpFD in
            if let id = self.userid?.data(using: .utf8) {
                mpFD.append(id, withName: "userid")
            }
            if let box = try? JSONSerialization.data(withJSONObject: self.bounding_boxes![box_index], options: []){
                mpFD.append(box, withName: "bounding_box")
            }
            if let jpegImage = image.jpegData(compressionQuality: 1) {
                mpFD.append(jpegImage, withName: "image", fileName: "actorImage", mimeType: "image/jpeg")
            }
        }, to: apiUrl, method: .post).response { response in
            switch (response.result) {
            case .success:
                guard let data = response.data, response.error == nil else {
                    print("findActor: NETWORKING ERROR")
                    return
                }
                if let httpStatus = response.response, httpStatus.statusCode != 200 {
                    print("findActor: HTTP STATUS: \(httpStatus.statusCode)")
                    return
                }
                
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                    print("findActor: failed JSON deserialization")
                    return
                }
                let actorName = jsonObj["actor"]! as? String ?? nil
                let actorConfidence = jsonObj["confidence"]! as? String ?? nil
                let actorImage = jsonObj["url"]! as? String ?? nil
                print(jsonObj)
                
                // No response
                if actorName == nil || actorConfidence == nil || actorImage == nil || actorName == "" {
                    self.waiting_for_find_actor = false
                    self.cant_find_actor = true
                    return
                }
                
                self.resultPage.actorName = actorName!
                self.resultPage.confidence = actorConfidence!
                self.resultPage.imageUrl = actorImage!
                self.waiting_for_find_actor = false
                self.found_actor = true
                self.box_index = box_index
                self.cant_find_actor = false
                
                print("Find Actor Returned Successfully!")
            case .failure:
                self.cant_find_actor = true
                print("Find Actor Failed!")
           }
        }
    }
}
