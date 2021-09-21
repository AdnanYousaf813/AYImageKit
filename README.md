# AYImageKit

AYImageKit is a Swift Library for Aysnc Image Downloading, Show Name's Initials and Can View image in Separate Screen.

# Features

* Aysnc Image Downloading.
* Can Show Text Initials.
* Can have Custom Styles.
* Can Preview Image In Separate Screen with Animation.
* Can Show ActivityIndicator while image loading.
* Can Add Placeholder Image.
* Can Cache Image In Memory.
* Can Cache Image In Disk.
* Can Make Round Image.
* Image Sharing Option.
* Work Well in Table View and Collection View cell.


# ScreenShot
![alt text](https://github.com/AdnanYousaf813/AYImageKit/blob/main/Preview1.gif)
![alt text](https://github.com/AdnanYousaf813/AYImageKit/blob/main/Preview2.gif)


## Installation
AYImageKit is only available via CocoaPods: 
```bash
pod 'AYImageKit'
```

## Usage

Via Storyboard.
1. Add View in controller.
2. Assign AYImageView Class to View.

![alt text](https://github.com/AdnanYousaf813/AYImageKit/blob/main/StoryBoard.jpg)

In View Controller Class.
1. If you only want to show Image.

```swift

import AYImageKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: AYImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView.currentViewController = self
        imageView.setImageFromUrl(url: "your url link here")
        
    }
}

```
2. If you want to show name's Initials in case of url broken or image is not available then.

```swift

imageView.currentViewController = self
imageView.text = "Adnan Yousaf"
imageView.setImageFromUrl(url: "your url link here")
       
```

3. If you want to placeholder Image in case of url broken or image is not available then.

```swift

imageView.currentViewController = self
imageView.placeHolderImage = UIImage(named: "")
imageView.setImageFromUrl(url: "your url link here")
       
```

4. If you want to set Image directly.

```swift

imageView.currentViewController = self
imageView.setImage(UIImage(named: ""))
       
```

5. If you want to set name's initials only.

```swift

imageView.showInitialsName("Adnan Yousaf")
       
```

6. Cache Properties

```swift

imageView.cacheInDisk = false
imageView.cacheInMemory = false
       
```

7. Styling

```swift

imageView.updateStyle(with: Style(font: UIFont.systemFont(ofSize: 34),
                                          textColor: UIColor.white,
                                          background: UIColor.black,
                                          borderColor: UIColor.black))
       
```

8. Other Properties

```swift

imageView.isCircular = true
/// if `true` AYImageView will be in circular shape. Default is `false`

imageView.isAllowToOpenImage = true 
// if `true` AYImageView will be interactive and can open ImageViewer. Default is `true`

imageView.isSharingEnabled = true 
// if `true` ImageViewerViewController will show a button to share image. Default is `true`

imageView.isShowActivityIndicator = true 
//if `true` AYImageViewer will show activity indicator during downloading image. Default is `true`

imageView.imageContentMode = .scaleAspectFill 
// set Image content mode of imageView. Default is `scaleAspectFit`

imageView.isforceRemoteFetchingEnabled = false 
//if `true` ImageDownloader will download image whether image is present in cache or not. Default is  `false`
   
```


For more Detail See Example project.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
AYImageKit is released under the [MIT](https://choosealicense.com/licenses/mit/) license.
