//
//  ImagePicker.swift
//  ActorCapture
//
//  Created by Jack  Rallo  on 3/15/22.
//

import SwiftUI
import UIKit

struct ImagePickerView: UIViewControllerRepresentable {

    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    @Binding var sourceType: UIImagePickerController.SourceType?
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        NSLog(self.sourceType == .photoLibrary ? "PHOTO" : "BRO WHAT THE FUCK")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType!
        imagePicker.delegate = context.coordinator 
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        NSLog("is this supposed to do anything")
    }
    
    func makeCoordinator() -> Coordinator {
        NSLog("coordinator")
        return Coordinator(picker: self)
    }
}


class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        NSLog("here")
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
