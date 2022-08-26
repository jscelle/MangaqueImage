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
        imageConverterView.image = #imageLiteral(resourceName: "solo")
        imageConverterView.contentMode = .scaleAspectFit
        
        mangaque.redrawImage(imageView: imageConverterView)
    }
}

