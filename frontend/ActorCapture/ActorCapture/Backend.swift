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
    @Published private(set) var bounding_boxes: [[[Int]]]?
    @Published private(set) var bounding_boxes_indices: [Int] = []
    @Published private(set) var waiting_for_find_faces = false
    @Published private(set) var scalingFactor: CGFloat = 0
    @Published private(set) var box_index : Int?
    @Published private(set) var resultPage = ResultPage()
    @Published private(set) var waiting_for_find_actor = false
    @Published public var found_actor = false
    @Published public var found_faces = false

    private let nFieldsHist = 5
    private let nFieldsWatch = 2

    private let serverUrl = "https://3.144.236.126/"
    
    private let userid = UIDevice.current.identifierForVendor?.uuidString
    
    func addWatchlist(_ moreInfo: MoreInfoEntry) async {
        guard let apiUrl = URL(string: serverUrl+"postwatchlist/") else {
            print("postwatchlist: Bad URL")
            return
        }
        
        let jsonObj = ["userid": userid, "movietitle": moreInfo.movieName, "imageURL" : moreInfo.imageUrl, ]
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
            let data2 : [String: Any] = [
                "known_for": [
                              ["id": "tt0369735", "title": "Monster-in-Law", "fullTitle": "Monster-in-Law (2005)", "year": "2005", "role": "Ruby", "image": "https://imdb-api.com/images/original/MV5BYTcwYjA1NGItM2YyYy00MmE4LTkxMzItYWNiZWRkNDFjNmE5L2ltYWdlL2ltYWdlXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_Ratio0.6852_AL_.jpg"],
                              ["id": "tt1667889", "title": "Ice Age 4: Continental Drift", "fullTitle": "Ice Age 4: Continental Drift (2012)", "year": "2012", "role": "Granny", "image": "https://imdb-api.com/images/original/MV5BMTM3NDM5MzY5Ml5BMl5BanBnXkFtZTcwNjExMDUwOA@@._V1_Ratio0.6852_AL_.jpg"],
                              ["id": "tt4651520", "title": "Bad Moms", "fullTitle": "Bad Moms (2016)", "year": "2016", "role": "Dr. Karl", "image": "https://imdb-api.com/images/original/MV5BMjIwNzE5MTgwNl5BMl5BanBnXkFtZTgwNjM4OTA0OTE@._V1_Ratio0.6852_AL_.jpg"],
                              ["id": "tt0413099", "title": "Evan Almighty", "fullTitle": "Evan Almighty (2007)", "year": "2007", "role": "Rita", "image": "https://imdb-api.com/images/original/MV5BMTUxMTEzODYxMV5BMl5BanBnXkFtZTcwNzQ4ODU0MQ@@._V1_Ratio0.6852_AL_.jpg"]],
                "cast_movies": [
                                ["id": "tt14831458", "role": "Actress", "title": "Tiny Tina's Wonderlands", "year": "2022", "description": "(Video Game) (post-production) Frette (voice)"],
                                ["id": "tt18257758", "role": "Actress", "title": "Alabama Jackson", "year": "2022", "description": "(TV Series) Harriet Tubman (voice)"],
                                ["id": "tt14403322", "role": "Actress", "title": "Pandemica", "year": "2021", "description": "(TV Mini Series) (voice)"]],
                
            ]
            self.actorinfo = [MoreInfoEntry]()
            if let whole_dict = data2["known_for"] as? [[String:String]] {
                for dict in whole_dict{
                    //print(dict["id"]!)
                    self.actorinfo.append(MoreInfoEntry(imageUrl: dict["image"]!, characterName: dict["role"],movieName: dict["fullTitle"]))
                }
            }else{
                print("getactorinfo failed 1")
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
    
    func deleteWatchlist(_ watchlist: WatchListEntry) async {
        let jsonObj = ["userid": userid,
                       "movietitle": watchlist.movieName]
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
    
    func reset_capture() {
        self.bounding_boxes = nil
        self.bounding_boxes_indices = []
        self.scalingFactor = 0
        self.box_index = nil
    }
    
    func set_box_index(_ ind: Int){
        self.box_index = ind
    }
    
    func set_waiting_for_find_faces(_ b: Bool) {
        self.waiting_for_find_faces = b
    }
    
    func set_waiting_for_find_actor(_ b: Bool) {
        self.waiting_for_find_actor = b
    }
    
    func set_found_actor(_ b: Bool) {
        self.found_actor = false
    }
    
    @MainActor
    func findFaces(_ image: UIImage) {
        guard let apiUrl = URL(string: serverUrl+"findfaces/") else {
            print("findFaces: Bad URL")
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
                    return
                }
                let temp_boxes = NSMutableArray(array: recBoundingBoxes!)
                let boxes = temp_boxes as NSArray as? [[[Int]]]
                
                var new_array: [[[Int]]] = []
                
                self.scalingFactor = CGFloat(300)/CGFloat(image.size.height)
                
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
                self.found_faces = true
                
                print("Find Faces Returned Successfully!")
            case .failure:
                print("Find Faces Failed!")
           }
        }
    }
    
    @MainActor
    func findActor(_ image: UIImage) {
        guard let apiUrl = URL(string: serverUrl+"findactor/") else {
            print("findFaces: Bad URL")
            return
        }
        
        AF.upload(multipartFormData: { mpFD in
            if let id = self.userid?.data(using: .utf8) {
                mpFD.append(id, withName: "userid")
            }
            if let box = try? JSONSerialization.data(withJSONObject: self.bounding_boxes![self.box_index!], options: []){
                mpFD.append(box, withName: "bounding_box")
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
                let actorName = jsonObj["actor"]! as? String ?? nil
                let actorConfidence = jsonObj["confidence"]! as? String ?? nil
                let actorImage = jsonObj["url"]! as? String ?? nil
                print(jsonObj)
                
                // No response
                if actorName == nil || actorConfidence == nil || actorImage == nil || actorName == "" {
                    self.waiting_for_find_actor = false
                    return
                }
                
                self.resultPage.actorName = actorName!
                self.resultPage.confidence = actorConfidence!
                self.resultPage.imageUrl = actorImage!
                self.waiting_for_find_actor = false
                self.found_actor = true
                
                print("Find Actor Returned Successfully!")
            case .failure:
                print("Find Actor Failed!")
           }
        }

    }
}
