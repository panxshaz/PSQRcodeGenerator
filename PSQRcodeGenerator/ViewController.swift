//
//  ViewController.swift
//  PSQRcodeGenerator
//
//  Created by Pankaj Sharma on 29/03/19.
//  Copyright © 2019 idevios. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var qrcodeTextField: NSTextField!
    @IBOutlet weak var qrcodeImageView: NSImageView!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var qrSaveLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrcodeTextField.preferredMaxLayoutWidth = 350
        qrcodeTextField.delegate = self
        self.downloadButton.attributedTitle = NSAttributedString(string: "DOWNLOAD", attributes: [NSAttributedString.Key.foregroundColor : NSColor.blue])
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func generateQRCode(from string: String) -> NSImage? {
        if let filter = CIFilter(name: "CIQRCodeGenerator"), string.count > 0 {
            let data = string.data(using: String.Encoding.ascii)
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext(options: nil)
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return NSImage(cgImage: cgImage, size: NSSize(width: 400, height: 400))
                }
            }
        }
        
        return nil
    }
    
    
    @IBAction func downloadQRcodeImage(_ sender: Any) {
        guard let image = self.qrcodeImageView.image else { return }
        let imageName = "\(qrcodeTextField.stringValue).png"
        if let _ = saveImageToDownloads(image: image, filename: imageName) {
            qrSaveLabel.stringValue = "QRcode generated for \(qrcodeTextField.stringValue)\nFile saved at ~/Downloads/\(imageName)"
            qrSaveLabel.animator().isHidden = false
        }
    }
    
    //Refer: http://fulmanski.pl/tutorials/apple/macos/top-main-menu/
    @IBAction func saveToDownloadsClicked(_ sender: NSMenuItem) {
        downloadQRcodeImage(sender)
    }

    
    @discardableResult func saveImageToDownloads(image: NSImage, filename: String) -> URL? {
        let destination = FileManager.default.urls(for: FileManager.SearchPathDirectory.downloadsDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!.appendingPathComponent(filename)
        if image.pngWrite(to: destination) {
            return destination            
        }
        return nil
    }
    



    //MARK: - NSTextFieldDelegate
    func controlTextDidChange(_ obj: Notification) {
        print("qrcodeTextField.stringValue : \(qrcodeTextField.stringValue)")
        if let image = generateQRCode(from: qrcodeTextField.stringValue) {
            self.qrcodeImageView.image = image
            downloadButton.isEnabled = true
        } else {
            self.qrcodeImageView.image = nil
            downloadButton.isEnabled = false
        }
        qrSaveLabel.animator().isHidden = true
    }
}



extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    //TODO: Add feature to scan QR from static image source
//    func parseQR() -> [String] {
//        guard let image = CIImage(image: self) else {
//            return []
//        }
//
//        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
//                                  context: nil,
//                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
//
//        let features = detector?.features(in: image) ?? []
//
//        return features.compactMap { feature in
//            return (feature as? CIQRCodeFeature)?.messageString
//        }
//    }
}
