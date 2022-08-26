//
//  CGRect + Convert.swift
//  converter
//
//  Created by Artem Raykh on 26.08.2022.
//

import Foundation
import UIKit


// MARK: CGRect convert
extension CGRect {
    func convert(to bounds: CGRect) -> CGRect {
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = self
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.minX
        rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
}

// MARK: Scale and orient UIImage
extension UIImage {
    ///  Scale and orient picture for Vision framework
    ///
    ///  From [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
    ///
    ///  - Parameter image: Any `UIImage` with any orientation
    ///  - Returns: An image that has been rotated such that it can be safely passed to Vision framework for detection.
    
    func scaleAndOrient() -> UIImage {
        
        // Set a default value for limiting image size.
        let maxResolution: CGFloat = 640
        
        guard let cgImage = self.cgImage else {
            print("UIImage has no CGImage backing it!")
            return self
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
        let orientation = self.imageOrientation
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
}

// MARK: Array
extension Array {
    func grouped(by equal: (Element, Element) -> Bool) -> [[Element]] {
        guard let firstElement = first else { return [] }
        guard let splitIndex = firstIndex(where: { !equal($0, firstElement) } ) else { return [self] }
        return [Array(prefix(upTo: splitIndex))] + Array(suffix(from: splitIndex)).grouped(by: equal)
    }
}

// MARK: CGRect
extension CGRect {
    
    func distance(from rect: CGRect) -> CGSize {
        if intersects(rect) {
            return CGSize(width: 0, height: 0)
        }
        
        let mostLeft = origin.x < rect.origin.x ? self : rect
        let mostRight = rect.origin.x < self.origin.x ? self : rect
        
        var xDifference = mostLeft.origin.x == mostRight.origin.x ? 0 : mostRight.origin.x - (mostLeft.origin.x + mostLeft.size.width)
        xDifference = CGFloat(max(0, xDifference))
        
        let upper = self.origin.y < rect.origin.y ? self : rect
        let lower = rect.origin.y < self.origin.y ? self : rect
        
        var yDifference = upper.origin.y == lower.origin.y ? 0 : lower.origin.y - (upper.origin.y + upper.size.height)
        yDifference = CGFloat(max(0, yDifference))
        
        return CGSize(width: xDifference, height: yDifference)
    }
}
