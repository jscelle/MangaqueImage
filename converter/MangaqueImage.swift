//
//  ImageLighter.swift
//  converter
//
//  Created by Artem Raykh on 24.08.2022.
//

import Foundation
import UIKit
import Vision

#warning("add options: background color, fill or show box, translation type, translate to language, etc")

struct Synopsis {
    let text: String
    let rect: CGRect
}


final class MangaqueImage {
    
    func recognizeText(
        imageView: UIImageView
        
    ) {
        
        guard let image = imageView.image else {
            return
        }
        
        guard let cgImage = image.cgImage else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: .up
        )
        
        let size = CGSize(
            width: cgImage.width,
            height: cgImage.height
        )
        
        let bounds = CGRect(
            origin: .zero,
            size: size
        )
        
        // MARK: Request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            
            guard let self = self else {
                return
            }
            
            guard let results = request.results as? [VNRecognizedTextObservation],
                  error == nil
            else {
                return
            }
            
            let rects = results.map {
                self.convert(
                    boundingBox: $0.boundingBox,
                    to: CGRect(
                        origin: .zero,
                        size: size
                    )
                )
            }
            
            let string = results.compactMap {
                $0.topCandidates(1).first?.string
            }
            
            let synopsisArray = results.compactMap { observation -> Synopsis? in
                
                let rect = self.convert(
                    boundingBox: observation.boundingBox,
                    to: CGRect(
                        origin: .zero,
                        size: size
                    )
                )
                
                guard let text = observation.topCandidates(1).first?.string else {
                    return nil
                }
                
                return Synopsis(
                    text: text,
                    rect: rect
                )
            }
            
            let unitedArray = self.groupCloseSynopsis(synopisArray: synopsisArray)
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            
            let final = UIGraphicsImageRenderer(
                bounds: bounds,
                format: format
            ).image { context in
                
                image.draw(in: bounds)
                
                for synopsis in unitedArray {
                    
                    let label = UILabel()
                    
                    label.font = .systemFont(ofSize: 30)
                    
                    label.adjustsFontSizeToFitWidth = true
                    
                    label.numberOfLines = 0
                    
                    label.backgroundColor = .black
                    label.textAlignment = .center
                    
                    label.bounds = synopsis.rect
                    
                    label.text = synopsis.text
                    label.textColor = .white
                    
                    label.layer.render(in: context.cgContext)
                    
                }
                
            }
            imageView.image = final
        }
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print("Failed to perform image request: \(error)")
            return
        }
    }
    
    /// Convert Vision coordinates to pixel coordinates within image.
    ///
    /// Adapted from `boundingBox` method from
    /// [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
    /// This flips the y-axis.
    ///
    /// - Parameters:
    ///   - boundingBox: The bounding box returned by Vision framework.
    ///   - bounds: The bounds within the image (in pixels, not points).
    ///
    /// - Returns: The bounding box in pixel coordinates, flipped vertically so 0,0 is in the upper left corner
    
    func convert(boundingBox: CGRect, to bounds: CGRect) -> CGRect {
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = boundingBox
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.minX
        rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
    ///  Scale and orient picture for Vision framework
    ///
    ///  From [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
    ///
    ///  - Parameter image: Any `UIImage` with any orientation
    ///  - Returns: An image that has been rotated such that it can be safely passed to Vision framework for detection.
    
    func scaleAndOrient(image: UIImage) -> UIImage {
        
        // Set a default value for limiting image size.
        let maxResolution: CGFloat = 640
        
        guard let cgImage = image.cgImage else {
            print("UIImage has no CGImage backing it!")
            return image
        }
        
        // Compute parameters for transform.
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        var transform = CGAffineTransform.identity
        
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        if width > maxResolution ||
            height > maxResolution {
            let ratio = width / height
            if width > height {
                bounds.size.width = maxResolution
                bounds.size.height = round(maxResolution / ratio)
            } else {
                bounds.size.width = round(maxResolution * ratio)
                bounds.size.height = maxResolution
            }
        }
        
        let scaleRatio = bounds.size.width / width
        let orientation = image.imageOrientation
        switch orientation {
        case .up:
            transform = .identity
        case .down:
            transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
        case .left:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
        case .right:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
        case .upMirrored:
            transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
        case .leftMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
        case .rightMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
        default:
            transform = .identity
        }
        
        return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
            let context = rendererContext.cgContext
            
            if orientation == .right || orientation == .left {
                context.scaleBy(x: -scaleRatio, y: scaleRatio)
                context.translateBy(x: -height, y: 0)
            } else {
                context.scaleBy(x: scaleRatio, y: -scaleRatio)
                context.translateBy(x: 0, y: -height)
            }
            context.concatenate(transform)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
    
    private func groupCloseSynopsis(synopisArray: [Synopsis]) -> [Synopsis] {
        
        #warning("there may be more elegant way")
        let sortedArray = synopisArray.sorted { first, second in
            first.rect.midX > second.rect.midX
        }.grouped { first, second in
            
            let differenceX = abs(first.rect.midX - second.rect.midX)
            let differenceY = abs(first.rect.midY - second.rect.midY)
            
            let offsetY = max(first.rect.height, second.rect.height) * 4
            let offsetX = min(first.rect.width, second.rect.width) / 4
            
            return differenceX < offsetX && differenceY < offsetY
            
        }.compactMap { array in
            array.sorted { first, second in
                first.rect.midY < second.rect.midY
            }
        }
        
        let unitedArray = sortedArray.compactMap { array -> Synopsis in
            
            let text = array.compactMap {
                $0.text
            }.joined(separator: "\n")
            
            let rect = array.reduce(CGRect.null) {
                $0.union($1.rect)
            }
            
            return Synopsis(
                text: text,
                rect: rect
            )
        }
        
        return unitedArray
    }
}

extension Array {
    func grouped(by equal: (Element, Element) -> Bool) -> [[Element]] {
        guard let firstElement = first else { return [] }
        guard let splitIndex = firstIndex(where: { !equal($0, firstElement) } ) else { return [self] }
        return [Array(prefix(upTo: splitIndex))] + Array(suffix(from: splitIndex)).grouped(by: equal)
    }
}
