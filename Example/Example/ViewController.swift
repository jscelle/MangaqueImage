//
//  ViewController.swift
//  Example
//
//  Created by Artem Raykh on 29.08.2022.
//

import UIKit
import MangaqueImage

class ViewController: UIViewController {
    
    @IBOutlet weak var contentImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mangaqueImage = MangaqueImage()
        
        let fakeTranslator = FakeTranslator()
        
        let backgroundColor = MangaqueColor.auto
        let textColor = MangaqueColor.auto
        
        mangaqueImage.redrawImage(
            image: #imageLiteral(resourceName: "Image"),
            translator: .none,
            textColor: textColor,
            backgroundColor: backgroundColor
        ) { [weak self] image, error in

            if let error = error {
                print(error)
            }

            if let image = image {
                self?.contentImageView.image = image
            }
        }
    }
}

class FakeTranslator: MangaqueTranslator {
    func performTranslate(untranslatedText: String, comletionHandler: @escaping (String?, Error?) -> ()) {
        // MARK: There is your own implementation
        comletionHandler("fake", nil)
    }
}
