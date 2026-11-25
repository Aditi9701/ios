import SwiftUI
import UIKit

public struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding public var selectedImage: UIImage?
    public var sourceType: UIImagePickerController.SourceType = .camera
    @Environment(\.presentationMode) private var presentationMode

    public init(selectedImage: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType = .camera) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Downsample & compress image to keep under 500 KB
                self.parent.selectedImage = image.compressed()
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

extension UIImage {
    func compressed(maxDimension: CGFloat = 1920, maxBytes: Int = 450 * 1024) -> UIImage {
        var actualWidth = size.width
        var actualHeight = size.height

        if actualWidth > maxDimension || actualHeight > maxDimension {
            if actualWidth > actualHeight {
                actualHeight = actualHeight * (maxDimension / actualWidth)
                actualWidth = maxDimension
            } else {
                actualWidth = actualWidth * (maxDimension / actualHeight)
                actualHeight = maxDimension
            }
        }

        let rect = CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: actualWidth, height: actualHeight), false, 1.0)
        draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()

        var compression: CGFloat = 0.82
        var data = resizedImage.jpegData(compressionQuality: compression)

        while (data?.count ?? 0) > maxBytes && compression > 0.3 {
            compression -= 0.1
            data = resizedImage.jpegData(compressionQuality: compression)
        }

        if let data = data, let finalImage = UIImage(data: data) {
            return finalImage
        }
        return resizedImage
    }
}
