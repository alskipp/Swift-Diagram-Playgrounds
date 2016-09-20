//: # Crustacean
//:
//: Enum-Oriented Programming with Value Types
import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
//: A `Diagram` as a recursive enum
enum Diagram {
  case Polygon(corners: [CGPoint])
  case Circle(center: CGPoint, radius: CGFloat)
  indirect case Scale(x: CGFloat, y: CGFloat, diagram: Diagram)
  case Diagrams([Diagram])
}
//: ## Extend CGContext
//:
//: A few simple wrapper functions for `CGContext`
extension CGContext {
  func move(to position: CGPoint) {
    CGContextMoveToPoint(self, position.x, position.y)
  }
  func addLine(to position: CGPoint) {
    CGContextAddLineToPoint(self, position.x, position.y)
  }
  func drawPath(points: [CGPoint]) {
    if let p = points.last {
      move(to: p)
      for p in points { addLine(to: p) }
    }
  }
  func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
    let arc = CGPathCreateMutable()
    CGPathAddArc(arc, nil, center.x, center.y, radius, startAngle, endAngle, true)
    CGContextAddPath(self, arc)
  }
  func scale(x: CGFloat, _ y: CGFloat, operation: CGContext -> ()) {
    CGContextSaveGState(self)
    CGContextScaleCTM(self, x, y)
    operation(self)
    CGContextRestoreGState(self)
  }
}
//: ## Do some drawing!
//:
//: A recursive function responsible for drawing a diagram into a CGContext
func drawDiagram(diagram: Diagram, context: CGContext) -> () {
  switch diagram {
  case let .Polygon(corners):
    context.drawPath(corners)
    
  case let .Circle(center, radius):
    context.addArc(center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    
  case let .Scale(x, y, diagram):
    context.scale(x, y) {
      drawDiagram(diagram, context: $0)
    }
    
  case let .Diagrams(diagrams):
    for d in diagrams { drawDiagram(d, context: context) }
  }
}
//: Infix operator for combining `Diagrams`
func + (d1: Diagram, d2: Diagram) -> Diagram {
  return .Diagrams([d1, d2])
}
//: ## Make some shapes
let circle = Diagram.Circle(center: CGPoint(x: 187.5, y: 333.5), radius: 93.75)

let triangle = Diagram.Polygon(corners: [
  CGPoint(x: 187.5, y: 427.25),
  CGPoint(x: 268.69, y: 286.625),
  CGPoint(x: 106.31, y: 286.625)])

let shape = circle + triangle
let diagram = shape + .Scale(x: 0.3, y: 0.3, diagram: shape)

// Show the diagram in the view. To see the result, View>Assistant
// Editor>Show Assistant Editor (opt-cmd-Return).
showCoreGraphicsDiagram { drawDiagram(diagram, context: $0) }

//: ## [Next](@next)
