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

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
