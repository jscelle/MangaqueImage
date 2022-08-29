//
//  ViewController.swift
//  converter
//
//  Created by Artem Raykh on 23.08.2022.
//

import SnapKit

class ViewController: UIViewController {
    
    let mangaque = MangaqueImage()
    
    @IBOutlet weak var imageConverterView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageConverterView.image = #imageLiteral(resourceName: "image2")
        imageConverterView.contentMode = .scaleAspectFit
        
        let fakeTranslator = FakeTranslator()
        
        mangaque.redrawImage(
            image: imageConverterView.image!,
            translator: .custom(translator: fakeTranslator),
            textColor: .auto,
            backgroundColor: .auto
        ) { [weak self] image, error in
            
            guard let self = self else {
                return
            }
            
            if let error = error {
                print(error)
            }
            
            if let image = image {
                self.imageConverterView.image = image
            }
        }
    }
}

class FakeTranslator: MangaqueTranslator {
    func performTranslate(
        untranslatedText: String,
        comletionHandler: @escaping (String?, Error?) -> ()
    ) {
        comletionHandler("fake translate", nil)
    }
}

