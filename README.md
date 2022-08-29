# MangaqueImage

MangaqueImage is a simple library based on 👁Apple Vision👁, which will allow you to find, automatically fill and translate text, redrawing input image.

## 💎Instalation💎

Instalation via SwiftPackages

## 🛠How to use🛠

# 🖼MangaqueImage image redraw🖼
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
# 📇MangaqueImage transaltor📇

You have to make your own translator implementation.
Just create a class what inherits from MangaqueTransaltor interface
There is "fake" translate implementation

```
class FakeTranslator: MangaqueTranslator {
    func performTranslate(untranslatedText: String, comletionHandler: @escaping (String?, Error?) -> ()) {
        // MARK: There is your own implementation
        comletionHandler("fake", nil)
    }
}
```

# 💙Mangaque Color💙

"Auto" option detects color of element automatically, but if you want to use specific color you can simply pass it

```
public enum MangaqueColor {
    case auto
    case custom(color: UIColor)
}
```

🏖Implementation🏖

```
// Green color of background
let backgroundColor = MangaqueColor.custom(color: UIColor.green)
// Auto color for text
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
```
# Example of work

Image before MangaqueImage redraw:

![Simulator Screen Shot - iPhone 12 - 2022-08-29 at 15 33 30](https://user-images.githubusercontent.com/77747763/187201942-facaf6fd-5937-43a7-99bd-80c1d90fa04d.png)

Image with custom custom(green background color) and auto text color:

![Simulator Screen Shot - iPhone 12 - 2022-08-29 at 15 32 15](https://user-images.githubusercontent.com/77747763/187202112-2a8a78f3-c255-42e7-b52f-59ae43365dd3.png)

Image with auto background and text color:

![Simulator Screen Shot - iPhone 12 - 2022-08-29 at 15 36 06](https://user-images.githubusercontent.com/77747763/187202381-251a1f95-d5a9-4790-a803-c33bbb7c500b.png)

🌊There is also example folder inside repository🌊
