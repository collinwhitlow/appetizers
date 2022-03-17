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
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType!
        imagePicker.delegate = context.coordinator
        imagePicker.allowsEditing = true
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}


class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    @ObservedObject var store = Backend.shared
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //print(info)
        var selectedImage: UIImage!
        if let img = info[.editedImage] as? UIImage {
            selectedImage = img
        }
        else if let img = info[.originalImage] as? UIImage {
            selectedImage = img
        }
        else { return }
        self.picker.selectedImage = selectedImage
        store.reset_capture()
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
