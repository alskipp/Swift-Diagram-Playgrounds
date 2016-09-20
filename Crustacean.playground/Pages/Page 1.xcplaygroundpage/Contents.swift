//: # Crustacean
//:
//: Protocol-Oriented Programming with Value Types
//: > **Important:**
//: > This is a preliminary document for an API or technology in development. Apple is supplying this information to help you plan for the adoption of the technologies and programming interfaces described herein for use on Apple-branded products. This information is subject to change, and software implemented according to this document should be tested with final operating system software and final documentation. Newer versions of this document may be provided with future betas of the API or technology. The license for this document is available [here](License).

import CoreGraphics
let twoPi = CGFloat(M_PI * 2)

//: A protocol for types that respond to primitive graphics commands.  We
//: start with the basics:
protocol Renderer {
    /// Moves the pen to `position` without drawing anything.
    func move(to position: CGPoint)
    
    /// Draws a line from the pen's current position to `position`, updating
    /// the pen position.
    func addLine(to point: CGPoint)
    
    /// Draws the fragment of the circle centered at `c` having the given
    /// `radius`, that lies between `startAngle` and `endAngle`, measured in
    /// radians.
    func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
}

//: A `Renderer` that prints to the console.
//:
//: Printing the drawing commands comes in handy for debugging; you
//: can't always see everything by looking at graphics.  For an
//: example, see the "nested diagram" section below.
struct TestRenderer : Renderer {
    func move(to p: CGPoint) { print("moveTo(\(p.x), \(p.y))") }
    
    func addLine(to p: CGPoint) { print("lineTo(\(p.x), \(p.y))") }
    
  func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        print("arcAt(\(center), radius: \(radius)," + " startAngle: \(startAngle), endAngle: \(endAngle))")
    }
}

//: An element of a `Diagram`.  Concrete examples follow.
protocol Drawable {
    /// Issues drawing commands to `renderer` to represent `self`.
    func draw(_ renderer: Renderer)
}

//: Basic `Drawable`s
struct Polygon : Drawable {
    func draw(_ renderer: Renderer) {
      renderer.move(to: corners.last!)
      for p in corners { renderer.addLine(to: p) }
    }
    var corners: [CGPoint] = []
}

struct Circle : Drawable {
    func draw(_ renderer: Renderer) {
      renderer.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    }
    var center: CGPoint
    var radius: CGFloat
}

//: Now a `Diagram`, which contains a heterogeneous array of `Drawable`s
/// A group of `Drawable`s
struct Diagram : Drawable {
    func draw(_ renderer: Renderer) {
        for f in elements {
            f.draw(renderer)
        }
    }
    mutating func add(other: Drawable) {
        elements.append(other)
    }
    var elements: [Drawable] = []
}

//: ## Retroactive Modeling
//:
//: Here we extend `CGContext` to make it a `Renderer`.  This would
//: not be possible if `Renderer` were a base class rather than a
//: protocol.
extension CGContext : Renderer {
    func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        let arc = CGMutablePath()
        arc.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        addPath(arc)
    }
}

var circle = Circle(center: CGPoint(x: 187.5, y: 333.5), radius: 93.75)

var triangle = Polygon(corners: [
    CGPoint(x: 187.5, y: 427.25),
    CGPoint(x: 268.69, y: 286.625),
    CGPoint(x: 106.31, y: 286.625)])

var diagram = Diagram(elements: [circle, triangle])

//: ## Putting a `Diagram` inside itself
//:
//: If `Diagram`s had reference semantics, we could easily cause an infinite
//: recursion in drawing just by inserting a `Diagram` into its own array of
//: `Drawable`s.  However, value semantics make this operation entirely
//: benign.
//:
//: To ensure that the result can be observed visually, we need to
//: alter the inserted diagram somehow; otherwise, all the elements
//: would line up exactly with existing ones.  This is a nice
//: demonstration of generic adapters in action.
//:
//: We start by creating a `Drawable` wrapper that applies scaling to
//: some underlying `Drawable` instance; then we can wrap it around
//: the diagram.

/// A `Renderer` that passes drawing commands through to some `base`
/// renderer, after applying uniform scaling to all distances.
struct ScaledRenderer : Renderer {
    let base: Renderer
    let scale: CGFloat
    
    func move(to p: CGPoint) {
        base.move(to: CGPoint(x: p.x * scale, y: p.y * scale))
    }
    
    func addLine(to p: CGPoint) {
        base.addLine(to: CGPoint(x: p.x * scale, y: p.y * scale))
    }
    
    func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        let scaledCenter = CGPoint(x: center.x * scale, y: center.y * scale)
        base.addArc(center: scaledCenter, radius: radius * scale, startAngle: startAngle, endAngle: endAngle)
    }
}

/// A `Drawable` that scales an instance of `Base`
struct Scaled<Base: Drawable> : Drawable {
    var scale: CGFloat
    var subject: Base
    
    func draw(_ renderer: Renderer) {
        subject.draw(ScaledRenderer(base: renderer, scale: scale))
    }
}

// Now insert it.
diagram.elements.append(Scaled(scale: 0.3, subject: diagram))

// Dump the diagram to the console. Use View>Debug Area>Show Debug
// Area (shift-cmd-Y) to observe the output.
diagram.draw(TestRenderer())

// Also show it in the view. To see the result, View>Assistant
// Editor>Show Assistant Editor (opt-cmd-Return).
showCoreGraphicsDiagram(title: "Diagram") { diagram.draw($0) }

//: ## [Next](@next)
