//
//  Capture.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/15/22.
//

import Foundation
import SwiftUI
import UIKit

struct CaptureView: View {
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var showingAlert = false
    
    @ObservedObject var store = Backend.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select or Take an Image of an Actor/Actress and Click Submit!")
                    .padding(.bottom, 30)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Rectangle())
                        .frame(width: 300, height: 300)
                } else {
                    Image(systemName: "person.crop.rectangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Rectangle())
                        .frame(width: 300, height: 300)
                }
                HStack {
                    Button() {
                        self.sourceType = .camera
                        self.isImagePickerDisplay.toggle()
                    } label: {
                        Image(systemName: "camera.fill")
                            .scaleEffect(3).padding(.trailing, 80)
                    }
                    
                    Button() {
                        self.sourceType = .photoLibrary
                        self.isImagePickerDisplay.toggle()
                    }  label: {
                        Image(systemName: "photo.fill")
                            .scaleEffect(3)
                    }
                    if selectedImage != nil {
                        Button() {
                            self.store.findFaces(selectedImage!)
                        } label: {
                            Image(systemName: "arrow.right.square.fill")
                                .scaleEffect(3).padding(.leading, 80)
                        }
                    }
                    else {
                        Button() {
                            showingAlert = true
                        } label: {
                            Image(systemName: "arrow.right.square.fill")
                                .scaleEffect(3)
                                .padding(.leading,80)
                                .foregroundColor(Color.gray)
                        }.alert("Please Select or Take an Image", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) {}
                        }
                    }
                }.padding(.top, 55)
            }.padding(.bottom, 125)
            //.navigationBarTitle("Demo")
            .sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
            
        }
    }
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView()
    }
}
