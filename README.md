# AYImageKit

AYImageKit is a swift library for aysnc downloading image and show on click.

# What it does



# ScreenShot
![alt text]https://github.com/AdnanYousaf813/AYImageKit/blob/main/Simulator%20Screen%20Shot%20-%20iPhone%208%20-%202021-09-20%20at%2012.36.14.png)

![alt text]https://github.com/AdnanYousaf813/AYImageKit/blob/main/Simulator%20Screen%20Shot%20-%20iPhone%208%20-%202021-09-20%20at%2012.37.04.png)

![alt text]https://github.com/AdnanYousaf813/AYImageKit/blob/main/Simulator%20Screen%20Shot%20-%20iPhone%208%20-%202021-09-20%20at%2012.36.17.png)

## Installation
AYImageKit is only available via CocoaPods: 
```bash
pod 'AYImageKit'
```

## Usage

* To reset timer on touch event, override sendEvent function.
* To get notify on touch event create protocol.

```swift
import UIKit

public protocol WindowDelegate: AnyObject {
    func window(_ window: Window, touchDetectedIn event: UIEvent)
}

public class Window: UIWindow {
    
    public weak var delegate: WindowDelegate?
    
    public override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        let touches = event.allTouches?
            .filter( { $0.phase == .began || $0.phase == .ended } ) ?? []
        if touches.count > 0 {
            delegate?.window(self, touchDetectedIn: event)
        }
        
    }
}
```

For more Detail See Example project.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
AYImageKit is released under the [MIT](https://choosealicense.com/licenses/mit/) license.
