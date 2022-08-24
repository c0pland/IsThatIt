import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	@IBOutlet weak var imageView: UIImageView!
	let imagePicker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		imagePicker.delegate = self
		imagePicker.sourceType = .camera
		imagePicker.allowsEditing = false
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			imageView.image = userImage
			guard let ciImage = CIImage(image: userImage) else {
				fatalError("Couldn't convert to CIImage")
			}
			detect(image: ciImage)
		}
		imagePicker.dismiss(animated: true)
		
	}
	
	func detect(image: CIImage) {
		guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
			fatalError("Error getting the model")
		}
		let request = VNCoreMLRequest(model: model) { request, error in
			guard let results = request.results as? [VNClassificationObservation] else {
				fatalError("Cannot convert results to VNClassificationObservation")
			}
			print(results)
			if let firstResult = results.first {
				self.navigationItem.title = "Isn't it a \(firstResult.identifier)?"
			}
		}
		let handler = VNImageRequestHandler(ciImage: image)
		do{
			try handler.perform([request])
		} catch {
			print(error)
		}
	}
	
	@IBAction func cameraTapped(_ sender: UIBarButtonItem) {
		present(imagePicker, animated: true)
	}
	
}

