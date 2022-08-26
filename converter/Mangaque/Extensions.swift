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

// MARK: UIImage scale and orient 
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

// MARK: Array group

extension Array {
    func grouped(by equal: (Element, Element) -> Bool) -> [[Element]] {
        guard let firstElement = first else { return [] }
        guard let splitIndex = firstIndex(where: { !equal($0, firstElement) } ) else { return [self] }
        return [Array(prefix(upTo: splitIndex))] + Array(suffix(from: splitIndex)).grouped(by: equal)
    }
}

// MARK: CGImage get color by rect

extension CGImage {
    func colors(at: [CGPoint]) -> [UIColor]? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
              let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return at.map { p in
            let i = bytesPerRow * Int(p.y) + bytesPerPixel * Int(p.x)
            
            let a = CGFloat(ptr[i + 3]) / 255.0
            let r = (CGFloat(ptr[i]) / a) / 255.0
            let g = (CGFloat(ptr[i + 1]) / a) / 255.0
            let b = (CGFloat(ptr[i + 2]) / a) / 255.0
            
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }
    
    func averageColorOf(rect: CGRect) -> UIColor {
        
        let points = [
            CGPoint(
                x: rect.minX,
                y: rect.minY
            ),
            CGPoint(
                x: rect.maxX,
                y: rect.minY
            ),
            CGPoint(
                x: rect.minX,
                y: rect.maxY
            ),
            CGPoint(
                x: rect.maxX,
                y: rect.maxY
            )
        ]
        
        guard let colors = colors(at: points) else {
            return .clear
        }
        
        return colors.blend()
    }
}

extension UIColor {
    func textColor() -> UIColor {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
        if (brightness < 0.3) {
            return UIColor.white
        }
        else {
            return UIColor.black
        }
    }
}

// MARK: Color array

extension Array where Element: UIColor {
    func blend() -> UIColor {
        let componentsSum = self.reduce((red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0))) { (temp, color) in
            guard let components = color.cgColor.components else { return temp }
            return (temp.0 + components[0], temp.1 + components[1], temp.2 + components[2])
        }
        let components = (red: componentsSum.red / CGFloat(self.count) ,
                          green: componentsSum.green / CGFloat(self.count),
                          blue: componentsSum.blue / CGFloat(self.count))
        return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: 1)
    }
}
// MARK: Label fabric
extension UILabel {
    static func createLabel(
        textColor: UIColor,
        backgroundColor: UIColor,
        bounds: CGRect,
        text: String
    ) -> UILabel {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 30)
        
        label.adjustsFontSizeToFitWidth = true
        
        label.numberOfLines = 0
        
        label.backgroundColor = backgroundColor
        label.textAlignment = .center
        
        label.bounds = bounds
        
        label.text = text
        label.textColor = textColor
        
        return label
    }
}
