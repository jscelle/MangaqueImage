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
    
    let mangaque = MangaqueImage()
    
    @IBOutlet weak var imageConverterView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageConverterView.image = #imageLiteral(resourceName: "Image-1")
        imageConverterView.contentMode = .scaleAspectFit
        
        mangaque.recognizeText(imageView: imageConverterView)
        
    }
}

