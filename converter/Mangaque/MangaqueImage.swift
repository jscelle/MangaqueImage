//
//  ImageLighter.swift
//  converter
//
//  Created by Artem Raykh on 24.08.2022.
//

import Foundation
import UIKit
import CoreImage

#warning("add options: background color, fill or show box, translation type, translate to language, etc")

final class MangaqueImage {
    
    private let processor = MangaqueImageProcessor()
    
    func redrawImage(
        image: UIImage,
        textColor: MangaqueColor,
        backgroundColor: MangaqueColor,
        completionHandler: @escaping (_ image: UIImage) -> ()
    ) {
        
        guard let cgImage = image.cgImage else {
            return
        }
        
        let size = CGSize(
            width: cgImage.width,
            height: cgImage.height
        )
        
        let bounds = CGRect(
            origin: .zero,
            size: size
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        processor.getSynopsises(
            cgImage: cgImage,
            orientation: .up,
            size: size
        ) { result, error in
            
            if let error = error {
                #warning("add errors")
            }
            
            if let result = result {
                
                let final = UIGraphicsImageRenderer(
                    bounds: bounds,
                    format: format
                ).image { context in
                    
                    image.draw(in: bounds)
                    
                    for synopsis in result {
                        
                        let bgColor: UIColor
                        let txtColor: UIColor
                        
                        switch backgroundColor {
                            case .custom(let color) :
                                bgColor = color
                            case .auto:
                                bgColor = cgImage.averageColorOf(rect: synopsis.rect)
                        }
                        
                        switch textColor {
                            case .custom(let color):
                                txtColor = color
                            case .auto:
                                txtColor = bgColor.textColor()
                        }
                        
                        let label = UILabel.createLabel(
                            textColor: txtColor,
                            backgroundColor: bgColor,
                            bounds: synopsis.rect,
                            text: synopsis.text
                        )
                        
                        label.layer.render(in: context.cgContext)
                    }
                }
                completionHandler(final)
            }
        }
    }
}
