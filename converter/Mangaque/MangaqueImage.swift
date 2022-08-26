//
//  ImageLighter.swift
//  converter
//
//  Created by Artem Raykh on 24.08.2022.
//

import Foundation
import UIKit

#warning("add options: background color, fill or show box, translation type, translate to language, etc")

final class MangaqueImage {
    
    private let processor = MangaqueImageProcessor()
    
    func redrawImage(
        imageView: UIImageView
    ) {
        
        guard let image = imageView.image else {
            return
        }
        
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
        }
    }
}

