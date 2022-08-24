//
//  ViewController.swift
//  converter
//
//  Created by Artem Raykh on 23.08.2022.
//

import SnapKit
import Vision
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var imageConverterView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageConverterView.image = #imageLiteral(resourceName: "image2")
        imageConverterView.getText()
    }
}

extension UIImageView {
    
    func getText() {
        let imageTranslator = ImageTranslator()
        
        guard let image = self.image else {
            return
        }
        
        let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: self.bounds)
        
        imageTranslator.getImageText(image: image) { synopsisArray in
            
            synopsisArray.forEach { synopsis in
                
                let normalizedRect = synopsis.absolutePosition.positionToRect()
                
                let testRect = synopsis.getConvertedRect(
                    boundingBox: normalizedRect,
                    inImage: imageRect.size,
                    containedIn: self.bounds.size
                )
                
                let rect = synopsis.getSpecificPosition(
                    imageRect: imageRect,
                    containerRect: CGRect.zero
                )
                
                let uiView = UIView(frame: testRect)
                self.addSubview(uiView)
                        
                uiView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
                uiView.layer.borderColor = UIColor.orange.cgColor
                uiView.layer.borderWidth = 3
            }
        }
    }
}

struct Synopsis {
    let text: String
    let absolutePosition: Position
    
    struct Position {
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
        
        func positionToRect() -> CGRect {
            let path = CGMutablePath()
            path.addLines(
                between: [
                    topLeft,
                    topRight,
                    bottomLeft,
                    bottomRight
                ]
            )
            return path.boundingBoxOfPath
        }
    }
    
    func getSpecificPosition(
        imageRect: CGRect,
        containerRect: CGRect
    ) -> CGRect {
        
        let position = Position(
            topLeft: specificPoint(
                absolutePoint: absolutePosition.topLeft,
                imageRect: imageRect,
                containerRect: containerRect
            ),
            topRight: specificPoint(
                absolutePoint: absolutePosition.topRight,
                imageRect: imageRect,
                containerRect: containerRect
            ),
            bottomLeft: specificPoint(
                absolutePoint: absolutePosition.bottomLeft,
                imageRect: imageRect,
                containerRect: containerRect
            ),
            bottomRight: specificPoint(
                absolutePoint: absolutePosition.bottomRight,
                imageRect: imageRect,
                containerRect: containerRect
            )
        )
        
        let path = CGMutablePath()
        path.addLines(
            between: [
                position.bottomLeft,
                position.topLeft,
                position.bottomRight,
                position.topRight
        ])
        
        return path.boundingBoxOfPath
    }
    
    func getConvertedRect(boundingBox: CGRect, inImage imageSize: CGSize, containedIn containerSize: CGSize) -> CGRect {
        
        let rectOfImage: CGRect
        
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        if imageAspect > containerAspect { /// image extends left and right
            let newImageWidth = containerSize.height * imageAspect /// the width of the overflowing image
            let newX = -(newImageWidth - containerSize.width) / 2
            rectOfImage = CGRect(x: newX, y: 0, width: newImageWidth, height: containerSize.height)
            
        } else { /// image extends top and bottom
            let newImageHeight = containerSize.width * (1 / imageAspect) /// the width of the overflowing image
            let newY = -(newImageHeight - containerSize.height) / 2
            rectOfImage = CGRect(x: 0, y: newY, width: containerSize.width, height: newImageHeight)
        }
        
        let newOriginBoundingBox = CGRect(
            x: boundingBox.origin.x,
            y: 1 - boundingBox.origin.y - boundingBox.height,
            width: boundingBox.width,
            height: boundingBox.height
        )
        
        var convertedRect = VNImageRectForNormalizedRect(newOriginBoundingBox, Int(rectOfImage.width), Int(rectOfImage.height))
        
        /// add the margins
        convertedRect.origin.x += rectOfImage.origin.x
        convertedRect.origin.y += rectOfImage.origin.y
        
        return convertedRect
    }
    
    private func specificPoint(
        absolutePoint: CGPoint,
        imageRect: CGRect,
        containerRect: CGRect
    ) -> CGPoint {
        // We getting specific point which belongs to rect we passed
        let calculatedX = absolutePoint.x * imageRect.size.width
        let calculatedY = (1 - absolutePoint.y) * imageRect.size.height
        
        let specificPoint = CGPoint(
            x: calculatedX + imageRect.origin.x,
            y: calculatedY
        )
        
        return specificPoint
    }
}

#warning("create errors")

open class ImageTranslator {
    
    func getImageText(
        image: UIImage,
        completionHandler: @escaping ([Synopsis]) -> ()
    ) {
        
        guard let cgImage = image.cgImage else {
            return
        }
        
        print(image.size.width / image.size.height)
        
        let hanlder = VNImageRequestHandler(
            cgImage: cgImage
        )
        
        
        let request = VNRecognizeTextRequest { result, error in
            
            guard let observation = result.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            var synopsisArray: [Synopsis] = []
            
            observation.forEach {
                
                guard let text = $0.topCandidates(1).first?.string else {
                    return
                }
                
                let absolutePosition = Synopsis.Position(
                    topLeft: $0.topLeft,
                    topRight: $0.topRight,
                    bottomLeft: $0.bottomLeft,
                    bottomRight: $0.bottomRight
                )
                
                let synopsis = Synopsis(
                    text: text,
                    absolutePosition: absolutePosition
                )
                
                synopsisArray.append(synopsis)
            }
            
            completionHandler(synopsisArray)
        }
        
        request.recognitionLevel = .fast
        
        do {
            try hanlder.perform([request])
        } catch {
            print(error)
        }
    }
}

