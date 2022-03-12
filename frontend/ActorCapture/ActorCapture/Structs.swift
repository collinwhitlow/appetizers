//
//  Structs.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/12/22.
//

import Foundation

struct HistoryEntry {
    var actorName: String?
    @ChattPropWrapper var imageUrl: String?
}

struct WatchListEntry {
    @ChattPropWrapper var imageUrl: String?
    var movieName: String?
}

struct MoreInfoEntry {
    @ChattPropWrapper var imageUrl: String?
    var characterName: String?
    var movieName: String?
}


@propertyWrapper
struct ChattPropWrapper {
    private var _value: String?
    var wrappedValue: String? {
        get { _value }
        set {
            guard let newValue = newValue else {
                _value = nil
                return
            }
            _value = (newValue == "null" || newValue.isEmpty) ? nil : newValue
        }
    }
    
    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue
    }
}
