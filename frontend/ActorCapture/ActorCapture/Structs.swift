//
//  Structs.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/12/22.
//

import Foundation
import SwiftUI
import UIKit

struct HistoryEntry {
    var actorName: String?
    @ChattPropWrapper var imageUrl: String?
    var confidence: String?
    var uid: String?
}

struct WatchListEntry {
    @ChattPropWrapper var imageUrl: String?
    var movieName: String?
    var uid: String?
}

struct MoreInfoEntry {
    @ChattPropWrapper var imageUrl: String?
    var characterName: String?
    var movieName: String?
}
struct MoreInfoKnownfor {
    @ChattPropWrapper var imageUrl: String?
    var characterName: String?
    var movieName: String?
}

struct ActorID {
    var actorID: String?
}

struct ResultPage {
    @ChattPropWrapper var imageUrl: String?
    var actorName: String?
    var confidence: String?
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
