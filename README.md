# MSCircularSlider
[![Travis](https://img.shields.io/travis/rust-lang/rust.svg)]() [![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/v/AFNetworking.svg)]() [![License](https://img.shields.io/cocoapods/l/AFNetworking.svg)]()

A fully `IBDesignable` and `IBInspectable` circular slider for iOS applications

------------------------
<p align="center">
  <img src="https://i.imgur.com/KOy1UHn.gif">
</p>

## Getting Started
MSCircularSlider provides a fluid and straightforward interface to a multipurpose slider UIControl. The entire library is written in Swift 4 along with the accompanying example project

### Installation
#### CocoaPods (recommended)
For the latest [CocoaPods](https://cocoapods.org/) release
```ruby
pod 'MSCircularSlider'
```
#### Manual Installation
Simply clone the entire repo and extract the files in the `MSCircularSlider` folder, then import them into your XCode project.

Or use one of the shorthand methods below
##### GIT
  - `cd` into your project directory
  - Use `sparse-checkout` to pull the library files only into your project directory
    ```sh
    git init MSCircularSlider
    cd MSCircularSlider
    git remote add -f origin https://github.com/ThunderStruct/MSCircularSlider.git
    git config core.sparseCheckout true
    echo "MSCircularSlider/*" >> .git/info/sparse-checkout
    git pull --depth=1 origin master
    ```
   - Import the newly pulled files into your XCode project
##### SVN
  - `cd` into your project directory
  - `checkout` the library files
    ```sh
    svn checkout https://github.com/ThunderStruct/MSCircularSlider/trunk/MSCircularSlider
    ```
  - Import the newly checked out files into your XCode project
  

### Usage
#### Initialization
Most members are `IBInspectable`, providing multiple ways of complete initialization; through the `Interface Builder` or programmatically
##### Interface Builder Initialization

<p>
  <img src="https://i.imgur.com/F4ZrBze.png">
</p>

##### Programmatic Initialization
The following code instantiates and initializes the slider to make it identical to the one in the IB sample above
```swift
let frame = CGRect(x: view.center.x - 200, y: view.center.y - 200, width: 400, height 400)     // center in superview
let slider = MSCircularSlider(frame: frame)
slider.currentValue = 60.0
slider.maximumAngle = 300.0
slider.filledColor = UIColor(red: 127 / 255.0, green: 168 / 255.0, blue: 198 / 255.0, alpha: 1.0)
slider.unfilledColor = UIColor(red: 80 / 255.0, green: 148 / 255.0, blue: 95 / 255.0, alpha: 1.0)
slider.handleType = .doubleCircle
slider.handleColor = UIColor(red: 35 / 255.0, green: 69 / 255.0, blue: 96 / 255.0, alpha: 1.0)
slider.handleEnlargementPoints = 12
slider.labels = ["1", "2", "3", "4", "5"]
view.addSubview(slider!)
```

### Members and Methods
#### MSCircularSlider
  - `delegate`: takes a class conforming to MSCircularSliderDelegate and handles delegation - default nil
  note: please check the _Protocols_ segment below for more info about the abstract delegation model used
  - `minimumValue`: the value the slider takes at angle 0° - default 0.0
  - `maximumValue`: the value the slider takes at maximumAngle - default 100.0
  - `currentValue`: the value the slider has at the current angle - default 0.0
  - `maximumAngle`: the arc's maximum angle (360° = full circle) - default 360.0
  - `lineWidth`: the arc's line width - default 5
  - `filledColor`: the color shown for the part "filled" by the handle - default .darkGrey
  - `unfilledColor`: the color shown for the "unfilled" part of the circle - default .lightGrey
  - `rotationAngle`: the rotation transformation angle of the entire slider view - default calculated so that the _gap_ is facing downwards
  note: the slider adds an inverted rotational transformation to all of its subviews to cancel any applied rotation
  - `handleType`: indicates the type of the handle - default .largeCircle
  - `handleColor`: the handle's color - default .darkGrey
  - `handleEnlargementPoints`: the number of points the handle is larger than lineWidth - default 10
  note: this property only applies to handles of types .largeCircle or .doubleCircle
  - `handleHighlightable`: indicates whether the handle should _highlight_ (becomes semitransparent) while being pressed - default true
  - `labels`: the string array that contains all labels to be displayed in an evenly-distributed manner - default [ ]
  note: all changes to this array will not be applied instantly unless they go through the assignment operator (=). To perform changes, use the provided methods below
  - `labelColor`: the color applied to the displayed labels - default .black
  - `snapToLabels`: indicates whether the handle should _snap_ to the nearest label upon handle-release - default false
  - `labelFont`: the font applied to the displayed labels - default .systemFont(ofSize: 12)
  - `labelOffset`: the number of point labels are pushed off away from the slider's center - default 0.0
  note: a negative number can be used to draw the labels inwards towards the center
  - `markerCount`: indicates the number of markers to be displayed in an evenly-distributed manner - default 0
  - `markerColor`: the color applied to the displayed markers - default .darkGrey
  - `markerPath`: an optional UIBezierPath to draw custom-shaped markers instead of the standard ellipse markers - default nil
  - `markerImage`: an optional UIImage to be drawn instead of the standard ellipse markers - default nil
  note: markerPath takes precedence over markerImage, so if both members are set, the images will not be drawn
  - `snapToMarkers`: indicates whether the handle should _snap_ to the nearest marker upon handle-release - default false
  note: if both snapToMarkers and snapToLabels are true, the handle will be snapped to the nearest marker
  - `addLabel(_ string: String)`: adds a string to the labels array and triggers required drawing methods
  - `changeLabel(at index: Int, string: String)`: replaces the label's string at the given index with the provided string
  - `removeLabel(at index: Int)`: removes the string from the labels array at the given index

#### MSDoubleHandleCircularSlider
Inherits from MSCircularSlider with the following differences

  - `delegate`: takes a class conforming to MSDoubleHandleCircularSliderDelegate and handles delegation - default nil
  note: please check the _Protocols_ segment below for more info about the abstract delegation model used
  - `minimumHandlesDistance`: indicates the minimum arc length between the two handles - default 10.0
  - `secondCurrentValue`: the current value of the second handle - default calculated from 60° angle
  - `snapToLabels`: from the super class - overridden and made unavailable
  - `snapToMarkers`: from the super class - overriden and made unavailable

#### MSGradientCircularSlider
Inherits from MSCircularSlider with the following differences

  - `gradientColors`: the colors array upon which the gradient is calculated (as ordered in the array) - default [.lightGray, .blue, .darkGray]
note: all changes to this array will not be applied instantly unless they go through the assignment operator (=). To perform changes, use the provided methods below
  - `addColor(_ color: UIColor)`: adds a color to the gradientColors array and triggers required drawing methods
  - `changeColor(at index: Int, newColor: UIColor)`: replaces the color at the given index with the provided newColor
  - `removeColor(at index: Int)`: removes the color from the gradientColors array at the given index

### Protocols  
There are three protocols used in the MSCircularSlider library

#### MSCircularSliderProtocol
An internal protocol that acts only as an abstract super class with no defined methods. The main and only `delegate` member exposed in all classes is of type MSCircularSliderProtocol and gets cast to one of the other two protocols appropriately

#### MSCircularSliderDelegate
Inherits from MSCircularSliderProtocol and contains all methods (documented below) used by MSCircularSlider and MSGradientCircularSlider

  - `circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool)`: called upon currentValue change and provides a _fromUser_ Bool that indicates whether the value was changed by the user (by scrolling the handle) or through other means (programmatically or so - `currentValue = 20`)
  
  - `circularSlider(_ slider: MSCircularSlider, startedTrackingWith value: Double)`: indicates that the handle started scrolling
  
  - `circularSlider(_ slider: MSCircularSlider, endedTrackingWith value: Double)`: indicates that the slider's handle was released

#### MSDoubleHandleCircularSliderDelegate
Inherits from MSCircularSliderProtocol and is used only by MSDoubleHandleCircularSlider

  - `circularSlider(_ slider: MSCircularSlider, valueChangedTo firstValue: Double, secondValue: Double, isFirstHandle: Bool?, fromUser: Bool) `: called upon any of the two current values changes and provides an isFirstHandle Bool indicating whether the change came from the first or second handle
  
  - `circularSlider(_ slider: MSCircularSlider, startedTrackingWith firstValue: Double, secondValue: Double, isFirstHandle: Bool)`: indicates that the handle started scrolling
  
  - `circularSlider(_ slider: MSCircularSlider, endedTrackingWith firstValue: Double, secondValue: Double, isFirstHandle: Bool)`: indicates that the active slider's handle was released

## Todos

 - Eliminate mutual-exlusion between `snapToLabels` and `snapToMarkers`
 - Add snapping feature for `MSDoubleHandleCircularSlider`
 - Add independent members for the second handle in `MSDoubleHandleCircularSlider` to customize each handle individually
 - Add `MSCircularSliderMaterial` enum that specifies different _finishes_ for the slider, including
   - Glossy
   - Matte
   - Pearlescent

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/ThunderStruct/MSCircularSlider/blob/master/LICENSE) file for details



