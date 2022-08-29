//
//  MangaqueImage.swift
//  converter
//
//  Created by Artem Raykh on 24.08.2022.
//

import Foundation
import UIKit

final class MangaqueImage {
    
    private let processor = MangaqueImageProcessor()
    
    func redrawImage(
        image: UIImage,
        translator: MangaqueTranslation,
        textColor: MangaqueColor,
        backgroundColor: MangaqueColor,
        completionHandler: @escaping (
            _ image: UIImage?,
            _ error: Error?
        ) -> ()
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
        
        processor.detectSynopsys(
            cgImage: cgImage,
            orientation: .up,
            size: size
        ) { [weak self] result, error in
            
            if let error = error {
                completionHandler(nil, error)
            }
            
            guard let self = self else {
                return
            }
            
            if let result = result {
                
                switch translator {
                case .none:
                    let redrawedImage = self.drawImage(
                        synopsisArray: result,
                        bounds: bounds,
                        image: image,
                        cgImage: cgImage,
                        backgroundColor: backgroundColor,
                        textColor: textColor
                    )
                    
                    completionHandler(redrawedImage, nil)
                    
                case .custom(let translator):
                    
                    var translatedSynopsisArray: [Synopsis] = []
                    let group = DispatchGroup()
                    
                    for synopsis in result {
                        group.enter()
                        translator.performTranslate(
                            untranslatedText: synopsis.text) { translatedText, error in
                                
                                if let error = error {
                                    completionHandler(nil, error)
                                }
                                
                                if let translatedText = translatedText {
                                    let translatedSynopsis = Synopsis(
                                        text: translatedText,
                                        rect: synopsis.rect
                                    )
                                    translatedSynopsisArray.append(translatedSynopsis)
                                }
                                group.leave()
                        }
                    }
                    group.wait()
                    
                    let redrawedImage = self.drawImage(
                        synopsisArray: translatedSynopsisArray,
                        bounds: bounds,
                        image: image,
                        cgImage: cgImage,
                        backgroundColor: backgroundColor,
                        textColor: textColor
                    )
                    
                    completionHandler(redrawedImage, nil)
                }
            }
        }
    }
    
    private func drawImage(
        synopsisArray: [Synopsis],
        bounds: CGRect,
        image: UIImage,
        cgImage: CGImage,
        backgroundColor: MangaqueColor,
        textColor: MangaqueColor
    ) -> UIImage  {
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let final = UIGraphicsImageRenderer(
            bounds: bounds,
            format: format
        ).image { context in
            
            image.draw(in: bounds)
            
            for synopsis in synopsisArray {
                
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
                
                setupLabel(
                    text: synopsis.text,
                    backgroundColor: bgColor,
                    textColor: txtColor,
                    bounds: synopsis.rect,
                    context: context.cgContext
                )
            }
        }
        
        return final
    }
    
    private func setupLabel(
        text: String,
        backgroundColor: UIColor,
        textColor: UIColor,
        bounds: CGRect,
        context: CGContext
    ) {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 30)
        
        label.adjustsFontSizeToFitWidth = true
        
        label.numberOfLines = 0
        
        label.backgroundColor = backgroundColor
        label.textAlignment = .center
        
        label.bounds = bounds
        
        label.text = text
        label.textColor = textColor
        
        label.layer.render(in: context)
    }
}
