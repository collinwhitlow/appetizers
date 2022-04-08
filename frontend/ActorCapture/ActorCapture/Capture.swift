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
    @State private var selectedImage: UIImage?
    @State private var box_index : Int?
    
    var body: some View {
        if !store.found_actor {
            ImageCapture(selectedImage: self.$selectedImage, box_index: self.$box_index)
        } else {
            ActorInfoCapture()
        }
    }
}

struct BoundingBoxes: View {
    //@Binding var box_index: Int?
    @ObservedObject var store = Backend.shared
    @Binding var box_index: Int?
    
    var body: some View {
        ForEach(store.bounding_boxes_indices, id: \.self) { index in
            Button(action: {
                if store.waiting_for_find_actor == true {} else {
                    self.box_index = index
                }
            }) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(index == self.box_index ? Color.green : Color.purple, lineWidth: 3)
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
    @ObservedObject var store = Backend.shared
    
    @Binding var selectedImage: UIImage?
    @Binding var box_index: Int?
    
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var isImagePickerDisplay = false
    @State private var showingAlert = false
    @State private var is_presenting_actor = false
    @State private var vstack_size : CGFloat = 670
    
    var body: some View {
        VStack {
            Spacer()
            Text(store.bounding_boxes == nil ? "Select Or Take An Image Of An Actor/Actress And Click Submit!" : "Select A Face And Click Submit!")
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
            Spacer()
                
            if selectedImage != nil {
                if store.bounding_boxes == nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .frame(width: 300, height: 300)
                        .clipped()
                        .opacity(store.waiting_for_find_faces ? 0.3 : 1)
                        .overlay(
                            ActivityIndicator(isAnimating: store.waiting_for_find_faces)
                                .padding()
                                .scaleEffect(2)
                        )
                } else {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .frame(width: 300, height: 300)
                        .clipped()
                        .opacity(store.waiting_for_find_actor ? 0.3 : 1)
                        .overlay(
                            BoundingBoxes(box_index: self.$box_index)
                        )
                        .overlay(
                            ActivityIndicator(isAnimating: store.waiting_for_find_actor)
                                .padding()
                                .scaleEffect(2)
                        )
                }
            } else {
                Image(systemName: "person.crop.rectangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Rectangle())
                    .frame(width: 300, height: 300)
            }
            Spacer()
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
                if selectedImage == nil || (store.bounding_boxes != nil && self.box_index == nil) || store.waiting_for_find_faces || store.waiting_for_find_actor {
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
                            if self.box_index != store.box_index {
                                store.set_waiting_for_find_actor(true)
                                self.store.findActor(selectedImage!, self.box_index!)
                            } else {
                                store.set_found_actor(true)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.right.square.fill")
                            .scaleEffect(3)
                            .foregroundColor(.green)
                    }.alert("Can't Find Any Faces", isPresented: $store.cant_find_faces) {
                        Button("OK", role: .cancel) {}
                    }.alert("Can't Find Name For Selected Face", isPresented: $store.cant_find_actor) {
                        Button("OK", role: .cancel) {}
                    }
                }
            }.frame(width: UIScreen.main.bounds.size.width, height: 75)
            Spacer()
        }
        .sheet(isPresented: self.$isImagePickerDisplay) {
            ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType, box_index: self.$box_index)
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
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Divider()
            if let imageUrl = store.resultPage.imageUrl! {
                AsyncImage(url: URL(string: imageUrl)!,
                           content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
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
                        .foregroundColor(.green)
                }
                
                Button() {
                    self.is_more_info_presenting.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .scaleEffect(3)
                        .foregroundColor(Color.blue)
                }
            }.padding(.top, 10)
        }.sheet(isPresented: self.$is_more_info_presenting) {
            ActorView(isPresented: $is_more_info_presenting, actorName: store.resultPage.actorName!, confidence: store.resultPage.confidence, actorUrl: store.resultPage.imageUrl!, history_or_capture: "capture")
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    fileprivate var configuration = { (indicator: UIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}


struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CaptureView()
                .previewDevice("iPhone 13 Pro Max")
                .previewInterfaceOrientation(.portrait)
            CaptureView()
                .previewInterfaceOrientation(.portrait)
        }
    }
}
