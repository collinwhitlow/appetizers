//
//  BoundingBox.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/16/22.
//

import Foundation
import UIKit
import CoreGraphics
import SwiftUI

//var arr



//var magenta = UIColor(rgb: 0xFF00FF)
var arr: [[Int]] = [[0,0], [100,100], [200, 200]]

struct BoundingBox: View{
    @State private var color = "red"
    let indices: [Int] = [0, 1, 2]
    
    var body: some View{
        Image(systemName: "person.crop.rectangle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(Rectangle())
            .frame(width: 300, height: 300)
            .overlay(
                    Button(action: {
                        change_color()
                    }) {
                        Rectangle()
                            .stroke(Color.red, lineWidth: 2)
                            //.position(x: 0, y: 0)
                            .frame(width: 100, height: 100)
                    }.frame(width: 100, height: 100).position(x: 100, y: 100)
            )
            
    }
    
    
    func change_color() {
        self.color = "blue"
    }
}

struct BoundingBox_Previews: PreviewProvider {
    static var previews: some View {
        BoundingBox()
.previewInterfaceOrientation(.portrait)
    }
}
 

