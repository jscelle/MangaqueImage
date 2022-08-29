# 🤓MangaqueImage🤓

MangaqueImage is a simple wrapper above the 👁Apple Vision👁 framework which will allow you to find, automatically fill and translate text, redrawing input image.

## Instalation

Instalation via SwiftPackages

## How to use

MangaqueImage for image redraw
```
import MangaqueImage

class ViewController: UIViewController {

    @IBOutlet weak var contentImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mangaqueImage = MangaqueImage()
        
        let fakeTranslator = FakeTranslator()
        
        mangaqueImage.redrawImage(
            image: #imageLiteral(resourceName: "Image"),
            translator: .custom(translator: fakeTranslator),
            textColor: .auto,
            backgroundColor: .auto
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

```
MangaqueImage transaltor 

```

class FakeTranslator: MangaqueTranslator {
    func performTranslate(untranslatedText: String, comletionHandler: @escaping (String?, Error?) -> ()) {
        // MARK: There is your own implementation
        comletionHandler("fake", nil)
    }
}

```
