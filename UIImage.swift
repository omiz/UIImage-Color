import UIKit
import Foundation
import AVFoundation

extension UIImage {


   var data: Data? {
      return UIImageJPEGRepresentation(self, 1)
   }

   var bytes: Int {
      return data?.count ?? 0
   }

   class var launchScreen: UIImage? {

      var found: UIImage? = nil

      let isLandscape = UIApplication.shared.statusBarOrientation.isLandscape

//      let isLandscape = UIDevice.current.orientation.isLandscape

      var size = UIScreen.main.bounds.size
      size = isLandscape ? CGSize(width: size.height, height: size.width) : size

      let viewOrientation = isLandscape ? "Landscape" : "Portrait"

      let imagesDict = Bundle.main.infoDictionary?["UILaunchImages"] as? NSArray ?? NSArray()

      imagesDict.forEach {
         guard let d = $0 as? NSDictionary else {
            return
         }
         let imageSize = CGSizeFromString(d["UILaunchImageSize"] as? String ?? "")
         let imageOriantation = d["UILaunchImageOrientation"] as? String ?? ""

         if imageSize.equalTo(size) && viewOrientation == imageOriantation {
            found = UIImage.init(named: d["UILaunchImageName"] as? String ?? "")
            return
         }
      }

      return found
   }

   convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      self.init(cgImage: image!.cgImage!)
   }

   class func from(url: URL) -> UIImage? {
      let asset = AVURLAsset(url: url)
      let generator = AVAssetImageGenerator(asset: asset)
      generator.appliesPreferredTrackTransform = true

      let timestamp = CMTime(seconds: 1, preferredTimescale: 60)

      let ref = try? generator.copyCGImage(at: timestamp, actualTime: nil)
      return ref == nil ? nil : UIImage(cgImage: ref!)
   }

   func with(color: UIColor) -> UIImage {
      guard let cgImage = self.cgImage else {
         return self
      }
      UIGraphicsBeginImageContextWithOptions(size, false, scale)
      let context = UIGraphicsGetCurrentContext()!
      context.translateBy(x: 0, y: size.height)
      context.scaleBy(x: 1.0, y: -1.0)
      context.setBlendMode(.normal)
      let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      context.clip(to: imageRect, mask: cgImage)
      color.setFill()
      context.fill(imageRect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext();
      return newImage
   }
}
