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
        imageConverterView.image = #imageLiteral(resourceName: "Image")
        imageConverterView.contentMode = .scaleAspectFit
        
        mangaque.redrawImage(
            image: imageConverterView.image!,
            textColor: .auto,
            backgroundColor: .auto
        ) { [weak self] image in
            
            guard let self = self else {
                return
            }
            
            self.imageConverterView.image = image
        }
    }
}

