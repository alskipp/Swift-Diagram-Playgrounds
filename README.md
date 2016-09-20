Swift-Diagram-Playgrounds
========

[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)

This is an adaption of Apple’s sample code for the [Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/wwdc/2015/?id=408) talk given during WWDC 2015.

Included is Apple’s original example playground file `Crustacean.playground` that uses a `Protocol-oriented` design (updated for Swift 3). In addition there's an alternative version `CrustaceanEnumOriented.playground` that uses a recursive enum as the data structure.

Finally there's the `Diagrams.playground` which adds a bit more functionality and includes several pages of example diagrams.

The playgrounds demonstrate two different approaches to creating `Diagram`s as value types and show how to draw them into a CGContext.

* * *

![screenshot](http://alskipp.github.io/Swift-Diagram-Playgrounds/img/screenshot1.png)

* * *

Apple’s version uses a variety of structs that conform to the `Drawable` protocol to represent different shapes. The alternative approach uses a recursive enum to achieve the same result. It looks like this:

```swift
public enum Diagram {
  case Polygon([CGPoint])
  case Line([CGPoint])
  case Arc(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
  case Circle(radius: CGFloat)
  indirect case Scale(x: CGFloat, y: CGFloat, diagram: Diagram)
  indirect case Translate(x: CGFloat, y: CGFloat, diagram: Diagram)
  indirect case Rotate(angle: CGFloat, diagram: Diagram)
  case Diagrams([Diagram])
}
```

* * *
**Note:** `livePreview` will merrily consume processing power to continuously redraw still images, therefore it's recommended to manually stop execution of the Playground after the images have rendered.
* * *

### Protocol-Oriented or Enum-Oriented – which is better?

The two approaches are a good demonstration of the [expression problem](https://en.wikipedia.org/wiki/Expression_problem). Which approach is easier to extend? Using a protocol-oriented technique allows you to add new types without too much hassle. In Apple’s example code a `Bubble` struct is added by implementing the `Drawable` protocol and `Equatable` (no pre-existing code needs to be adjusted). If a `Bubble` case were added to the `enum` version it would necessitate the altering of pre-existing functions (`Equatable` for `Diagram` and the `drawDiagram` function) this is more hassle and more error prone. However, we don't need to add a new case to the enum to draw `Bubble`s, we can simply add a function that constructs a bubble and returns a `Diagram`, in that case no code needs to be altered.

The use of a `Renderer` protocol makes it much easier to add a `TestRenderer` to log drawing. But using the `Renderer` protocol to add diagram transformation functionality is potentially very cumbersome. It is easy to add a `ScaledRenderer` type, but it would be more complicated to add a `TranslateRenderer`, or a `RotateRenderer` and duplicates functionality that is already provided by `CGContext`. The enum approach doesn't attempt to provide the logic for `Diagram` transformation, it simply stores the information needed and uses `CGContext` functions to do the hard work.

Which approach is better? I dunno ¯\\\_(ツ)_/¯