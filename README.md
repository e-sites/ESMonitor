# ESMonitor
> A draggable system monitor inside your application.
> Shake to show.

[![forthebadge](http://forthebadge.com/images/badges/made-with-swift.svg)](http://forthebadge.com) [![forthebadge](http://forthebadge.com/images/badges/compatibility-betamax.svg)](http://forthebadge.com)

Compatible with:

- Swift 4
- Xcode 9
- Cocoapods 1.3

## Example
![example](Assets/screenshot.png)


## Usage
### Init
```swift
import ESMonitor

func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window?.rootViewController = MainViewController(nibName: nil, bundle: Bundle.main)
        self.window?.makeKeyAndVisible()
    #if DEBUG
            let monitor = window.addMonitor()
            monitor.isHidden = true
    #endif
    return true
}
```