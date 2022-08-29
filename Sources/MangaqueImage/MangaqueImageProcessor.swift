//
//  MangaqueImageProcceser.swift
//  converter
//
//  Created by Artem Raykh on 26.08.2022.
//

#if canImport(UIKit)
import UIKit
import Vision

public class MangaqueImageProcessor {
    
    public init() {}
    
    func detectSynopsis(
        cgImage: CGImage,
        orientation: CGImagePropertyOrientation,
        size: CGSize,
        completionHandler: @escaping (
            _ result: [Synopsis]?,
            _ error: Error?
        ) -> ()
    ) {
        
        let imageRequestHandler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation
        )
        
        // MARK: Request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            
            guard let self = self else {
                return
            }
            
            guard let results = request.results as? [VNRecognizedTextObservation],
                  error == nil
            else {
                completionHandler(nil, error)
                return
            }
            
            let synopsisArray = results.compactMap { observation -> Synopsis? in
                
                let rect = observation.boundingBox.convert(
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
            
            completionHandler(unitedArray, nil)
        }
        
        do {
            try imageRequestHandler.perform([request])
        } catch {
            completionHandler(nil, error)
            return
        }
    }
    
    private func groupCloseSynopsis(
        synopisArray: [Synopsis]
    ) -> [Synopsis] {
        let sortedArray = synopisArray.sorted { first, second in
            
            first.rect.midX > second.rect.midX
            
        }.grouped { first, second in
            
            let differenceX = abs(first.rect.midX - second.rect.midX)
            let offsetX = min(first.rect.width, second.rect.width) / 4
            
            return differenceX < offsetX
            
        }.compactMap { array in
            
            array.sorted { first, second in
                first.rect.midY < second.rect.midY
            }
            
        }.compactMap { array in
            
            array.grouped { first, second in
                
                return first.rect.midY - second.rect.midY < 300
                
            }
            
        }.joined()
        
        
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
#endif
