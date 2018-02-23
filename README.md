
# Mapfit iOS SDK
> The Mapfit iOS SDK packages up everything you need to use Mapfit's services in your iOS applications.

## Features

- [x] Create a map
- [x] Add a marker to your map
- [x] Draw a route on your map
- [x] Display directions
- [x] Show info for a place

## Requirements

- iOS 11.0+
- Xcode 9

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `Mapfit` by adding it to your `Podfile`:

```ruby
platform :ios, '11.0'
use_frameworks!
pod 'Mapfit'
```

To get the full benefits import `YourLibrary` wherever you import UIKit

``` swift
import UIKit
import Mapfit
```

## Usage example

```swift
import Mapfit
```

## Set your API Key

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      MFTManager.sharedManager.apiKey = "API_KEY"
      return true
    }
}
```


## Create your map

```swift
let mapView = MFTMapView(frame: view.bounds)
view.addSubview(mapView)
```


## Add a marker to your map

```swift
let marker = mapView.addMarker(position:  CLLocationCoordinate2D(latitude: 40.74699, longitude: -73.98742))
```

## Contribute

We would love you for the contribution to the Mapfit iOS SDK, check the ``LICENSE`` file for more info.
