//: # Crustacean
//:
//: Enum-Oriented Programming with Value Types
import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
//: A `Diagram` as a recursive enum
enum Diagram {
  case polygon(corners: [CGPoint])
  case circle(center: CGPoint, radius: CGFloat)
  indirect case scale(x: CGFloat, y: CGFloat, diagram: Diagram)
  case diagrams([Diagram])
}
//: ## Extend CGContext
//:
//: A few simple wrapper functions for `CGContext`
extension CGContext {
  func drawPath(_ points: [CGPoint]) {
    if let p = points.last {
      move(to: p)
      for p in points { addLine(to: p) }
    }
  }
  func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
    let arc = CGMutablePath()
    arc.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    addPath(arc)
  }
  func scale(x: CGFloat, y: CGFloat, operation: (CGContext) -> ()) {
    saveGState()
    scaleBy(x: x, y: y)
    operation(self)
    restoreGState()
  }
}
//: ## Do some drawing!
//:
//: A recursive function responsible for drawing a diagram into a CGContext
func drawDiagram(_ diagram: Diagram, context: CGContext) -> () {
  switch diagram {
  case let .polygon(corners):
    context.drawPath(corners)

  case let .circle(center, radius):
    context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: twoPi)

  case let .scale(x, y, diagram):
    context.scale(x: x, y: y) {
      drawDiagram(diagram, context: $0)
    }

  case let .diagrams(diagrams):
    for d in diagrams { drawDiagram(d, context: context) }
  }
}
//: Infix operator for combining `Diagrams`
func + (d1: Diagram, d2: Diagram) -> Diagram {
  return .diagrams([d1, d2])
}
//: ## Make some shapes
let circle = Diagram.circle(center: CGPoint(x: 187.5, y: 333.5), radius: 93.75)

let triangle = Diagram.polygon(corners: [
  CGPoint(x: 187.5, y: 427.25),
  CGPoint(x: 268.69, y: 286.625),
  CGPoint(x: 106.31, y: 286.625)])

let shape = circle + triangle
let diagram = shape + .scale(x: 0.3, y: 0.3, diagram: shape)

// Show the diagram in the view. To see the result, View>Assistant
// Editor>Show Assistant Editor (opt-cmd-Return).
showCoreGraphicsDiagram { drawDiagram(diagram, context: $0) }

//: ## [Next](@next)
