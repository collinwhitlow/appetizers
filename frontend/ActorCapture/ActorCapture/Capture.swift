//
//  Capture.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/15/22.
//

import Foundation
import SwiftUI
import UIKit
import CoreGraphics

struct CaptureView: View {
    @ObservedObject var store = Backend.shared
    
    var body: some View {
        if !store.found_actor {
            ImageCapture()
        } else {
            ActorInfoCapture()
        }
    }
}

struct BoundingBoxes: View {
    //@Binding var box_index: Int?
    @ObservedObject var store = Backend.shared
    
    var body: some View {
        ForEach(store.bounding_boxes_indices, id: \.self) { index in
            Button(action: {
                store.waiting_for_find_actor ? nil : store.set_box_index(index)
            }) {
                Rectangle()
                    .stroke(index == store.box_index ? Color.green : Color.purple, lineWidth: 3)
                    .frame(width: self.find_width(index), height: self.find_height(index))
            }.frame(width: self.find_width(index), height: self.find_height(index))
             .position(x: find_x_pos(index) , y: find_y_pos(index))
        }
    }
    
    func find_width(_ index: Int) -> CGFloat{
        return (CGFloat(store.bounding_boxes![index][2][0]) - CGFloat(store.bounding_boxes![index][0][0])) * store.scalingFactor
    }
    
    func find_height(_ index: Int) -> CGFloat {
        return (CGFloat(store.bounding_boxes![index][2][1]) - CGFloat(store.bounding_boxes![index][0][1])) * store.scalingFactor
    }
    
    func find_x_pos(_ index: Int) -> CGFloat {
        return CGFloat(store.bounding_boxes![index][4][0]) * store.scalingFactor
    }
    
     func find_y_pos(_ index: Int) -> CGFloat {
         CGFloat(store.bounding_boxes![index][4][1]) * store.scalingFactor
    }
}

struct ImageCapture: View {
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var showingAlert = false
    //@State private var box_index : Int?
    @State private var is_presenting_actor = false
    
    @ObservedObject var store = Backend.shared
    
    var body: some View {
        VStack (alignment: .center, spacing: 50) {
            Text(store.bounding_boxes == nil ? "Select Or Take An Image Of An Actor/Actress And Click Submit!" : "Select A Face And Click Submit!")
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                
            if selectedImage != nil {
                if store.bounding_boxes == nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Rectangle())
                        .frame(width: 300, height: 300)
                        .clipped()
                        .opacity(store.waiting_for_find_faces ? 0.3 : 1)
                } else {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Rectangle())
                        .frame(width: 300, height: 300)
                        .clipped()
                        .overlay(
                            BoundingBoxes()
                        )
                        .opacity(store.waiting_for_find_actor ? 0.3 : 1)
                }
            } else {
                Image(systemName: "person.crop.rectangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Rectangle())
                    .frame(width: 300, height: 300)
            }
            HStack(alignment: .center, spacing: 80) {
                Button() {
                    self.sourceType = .camera
                    self.isImagePickerDisplay.toggle()
                } label: {
                    Image(systemName: "camera.fill")
                        .scaleEffect(3)
                }
                
                Button() {
                    self.sourceType = .photoLibrary
                    self.isImagePickerDisplay.toggle()
                }  label: {
                    Image(systemName: "photo.fill")
                        .scaleEffect(3)
                }
                if selectedImage == nil || (store.bounding_boxes != nil && store.box_index == nil) || store.waiting_for_find_faces || store.waiting_for_find_actor {
                    Button() {
                        self.showingAlert = true
                    } label: {
                        Image(systemName: "arrow.right.square.fill")
                            .scaleEffect(3)
                            .foregroundColor(Color.gray)
                    }.alert(store.waiting_for_find_faces ? "Waiting For Response!" : store.bounding_boxes != nil ? "Please Select A Face!" : "Please Select or Take an Image", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) {}
                    }
                }
                else {
                    Button() {
                        if store.bounding_boxes == nil {
                            store.set_waiting_for_find_faces(true)
                            self.store.findFaces(selectedImage!)
                        } else {
                            store.set_waiting_for_find_actor(true)
                            self.store.findActor(selectedImage!)
                        }
                    } label: {
                        Image(systemName: "arrow.right.square.fill")
                            .scaleEffect(3)
                    }/*.alert("Can't Find Name For Selected Face", isPresented: $cantFindActorFace) {
                        Button("OK", role: .cancel) {}
                    }.alert("Can't Find Any Faces", isPresented: $cantFindFace) {
                        Button("OK", role: .cancel) {}
                    }*/
                }
            }.padding(.top, 10)
            Spacer()
        }
        .sheet(isPresented: self.$isImagePickerDisplay) {
            ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType)
        }
    }
}

struct ActorInfoCapture: View {
    @ObservedObject var store = Backend.shared
    @State var is_more_info_presenting = false
    
    var body: some View {
        VStack (alignment: .center, spacing: 50) {
            Text(store.resultPage.actorName!)
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .frame(alignment: .top)
            Divider()
            if let imageUrl = store.resultPage.imageUrl! {
                AsyncImage(url: URL(string: imageUrl)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Rectangle())
                                    .frame(width:100, height: 100)
                                    .padding()
                                    },
                           placeholder: {
                               ProgressView()
                           })
            }
            Divider()
            Text("Confidence: " + String(store.resultPage.confidence!))
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .frame(alignment: .center)

            Divider()
            HStack(alignment: .center, spacing: 80) {
                Button() {
                    store.set_found_actor(false)
                } label: {
                    Image(systemName: "arrow.left.square.fill")
                        .scaleEffect(3)
                }
                
                Button() {
                    self.is_more_info_presenting.toggle()
                } label: {
                    Image(systemName: "info")
                        .scaleEffect(3)
                        .foregroundColor(Color.blue)
                }
            }.padding(.top, 10)
        }.sheet(isPresented: self.$is_more_info_presenting) {
            ActorView(isPresented: $is_more_info_presenting, actorName: store.resultPage.actorName!, confidence: store.resultPage.confidence, actorUrl: store.resultPage.imageUrl!, history_or_capture: "capture")
        }
    }
    //TODO - add sheet for more info
}


struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView()
.previewInterfaceOrientation(.portrait)
    }
}
