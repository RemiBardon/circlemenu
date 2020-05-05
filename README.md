[![Version](https://img.shields.io/cocoapods/v/EGOCircleMenu.svg?style=flat)](https://cocoapods.org/pods/EGOCircleMenu)
[![License](https://img.shields.io/cocoapods/l/EGOCircleMenu.svg?style=flat)](https://cocoapods.org/pods/EGOCircleMenu)
[![Platform](https://img.shields.io/cocoapods/p/EGOCircleMenu.svg?style=flat)](https://cocoapods.org/pods/EGOCircleMenu)

[![eGo-CMS](https://rawgithub.com/ego-cms/Resources/master/Badges_by_EGO/by_EGO.svg)](http://ego-cms.com/?utm_source=github)

# CircleMenu

## Table of contents

* [Introduction](../..#introduction)
* [Requirements](../..#requirements)
* [License](../..#license)
* [Installation](../..#installation)
* [Documentation](../..#documentation)
* [Sample](../..#sample)

<img src="Resources/animation.gif" width="400"/>

## Introduction

**CircleMenu** - this is a simple menu that contains buttons that are arranged in a circle one by one. It supports left/right/up/down swipes on both platforms. 
Every button can contain submenu, with other buttons. Submenu buttons have two states: open and close. In close state submenu buttons are invisible and the parent button has a blue indicator. If submenu buttons are in the opened state they are located near parent button (relative to each other they are located one above the other with an indicator on the top). For changing state you should tap on the base button which contains the submenu.
Menu buttons move by a circular arc with a center in the center of the main menu. Menu buttons have static positions on the screen. The angle between positions is 40 degrees. Scrolling menu implemented by an arc from one to other static positions. Every movement around has a spring/bounce animation at the end. Open and close animations move to static positions too, but unlike the scroll, each menu moves across several static positions (the first menu moves across all positions to the end, next menu moves across all positions, excepts last position and etc).

## Requirements

* iOS 11.0 and higher

## License

CircleMenu is available under the MIT license. See the LICENSE file for more info.

## Installation

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
gem install cocoapods
```

To integrate CircleMenu into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

# Apple blocked utilizing external frameworks on free accounts with 13.3.1 upgrade
# Comment `use_frameworks!` and use static libraries instead if you're on a free account
# https://stackoverflow.com/a/60211703/10967642
#use_modular_headers!

pod 'EGOCircleMenu'
```

Then, run the following command:

```bash
pod install
```

## Documentation

### Properties

* ```swift
  public var circleMenuItems: [CircleMenuItemModel] { get set }
  ```

  This property contains sequence of the models for buttons.

* ```swift
  public var unfocusedBackgroundColor: UIColor { get set }
  ```

  Button's background color in the regular state.

* ```swift
  public var focusedBackgroundColor: UIColor { get set }
  ```

  Button's background color in the pressed state.

* ```swift
  public var unfocusedIconColor: UIColor { get set }
  ```

  Button's icon color in the regular state.

* ```swift
  public var focusedIconColor: UIColor { get set }
  ```

  Button's icon color in the pressed state.

* ```swift
  public var tappingShadowViewCloses: ClosingPossibility { get set }
  ```

  Variable indicating what a tap on the blackout view should do. There are 5 possible cases explained below.

  * `.none` - Tapping on the blackout view does nothing
  * `.submenuOnly` - Tapping on the blackout view closes submenu if open, and does nothing otherwise
  * `.menuOnly` - Tapping on the blackout view closes menu if no submenu is open, and does nothing otherwise
  * `.all` - Tapping on the blackout view closes both submenu and menu if open, but one at a time (it takes two taps to close the menu if a submenu is open)
  * `.allAtTheSameTime` - Tapping on the blackout view closes both submenu and menu, at the same time. If a submenu is open or not, tapping on the blackout view closes the menu.

* ```swift
  public private(set) var openedSubmenu: CircleMenuButton? { get }
  ```

  Variable containing the opened submenu if one is open, `nil` otherwise.

### Methods

* ```swift
  public func attach(to viewController: UIViewController)
  ```
  
  Adds the menu to the bottom right corner of the view for current `viewController`.

* ```swift
  @objc public func openMenu()
  ```

  Opens the menu.

* ```swift
  @objc public func closeMenu()
  ```

  Closes the menu. Can be called in a Objective-C `Selector`.

  ```swift
  button.addTarget(circleMenu, action: #selector(CircleMenu.closeMenu), for: .touchUpInside)
  ```

### Limitations

The general circle menu must contain from 3 to 9 buttons. Each submenu should contain from 1 to 5 buttons.
We compute the menu frame from the general `UIView` of the `UIViewController`. This means that if you want to install banner ads at the bottom of the screen, you would see menu button above your banner.
`CircleMenuItemModel` has initializer which includes id, icons source and an array of submenus if they exist. In this case user should generate unique id because button menu clicked identification implemented by using id. `.touchUpInside` event handler delegate must be conformed with `CircleMenuDelegate` protocol and must override `menuItemSelected(id: Int)` method, where id is button menu identifier.

Circle menu uses native spring animation effects. We use UIView with a clear background to place all menu buttons. But it will not be a problem for using views that placed under the circle menu view, because we overrode the `hitTest(:CGPoint,:UIEvent?)` method. We use only 6 physical buttons with caching for performance purpose. We use Lottie animation for the hamburger button.

**Hamburger main button has id = 100 by default**

### Models

```swift
public class CircleMenuItemModel {

    public var id: Int?
    public var imageSource: UIImage?
    public var children: [CircleMenuItemModel]
    public var hasChildren: Bool { get }

    public init(id: Int?, imageSource: UIImage?, children: [CircleMenuItemModel]? = nil)

}
```

## Sample

```swift
import EGOCircleMenu

class ViewController: UIViewController, CircleMenuDelegate {

    var icons = ["icImage", "icPanorama", "icVideo", "icPhoto","icTimelapse","icMacro", "icPortrait", "icSeries", "icTimer", "icSixteenToNine", "icOneToOne", "icHDR"]
    let submenuIds = [2,3]

    override func viewDidLoad() {
        super.viewDidLoad()

        let circleMenu = CircleMenu()
        circleMenu.attach(to: self)
        circleMenu.delegate = self

        // Here you can customize needed properties
        circleMenu.circleMenuItems = createCircleMenuItems(count: 9)

        circleMenu.focusedIconColor         = .red
        circleMenu.unfocusedIconColor       = .green
        circleMenu.focusedBackgroundColor   = .black
        circleMenu.unfocusedBackgroundColor = .yellow
        circleMenu.blackoutColor            = UIColor.black.withAlphaComponent(0.5)

        circleMenu.tappingShadowViewCloses = .none // In [.none, .submenuOnly, .menuOnly, .all, .allAtTheSameTime]
    }

    func menuItemSelected(id: Int) {
        // Your .touchUpInside event handler
    }

    private func createCircleMenuItems(count: Int) -> [CircleMenuItemModel] {
        var menuModels = [CircleMenuItemModel]()
        for i in 0..<count {
            let menuModel = CircleMenuItemModel(id: i, imageSource: UIImage.init(named: icons[i]))
            if submenuIds.contains(i){
                for j in  9..<12 {
                    let submenuModel = CircleMenuItemModel(id: j, imageSource: UIImage.init(named: icons[j]))
                    menuModel.children.append(submenuModel)
                }
            }
            menuModels.append(menuModel)
        }
        return menuModels
    }

}
```

[![License](https://rawgit.com/ego-cms/Resources/master/License/license.svg)](LICENSE)
