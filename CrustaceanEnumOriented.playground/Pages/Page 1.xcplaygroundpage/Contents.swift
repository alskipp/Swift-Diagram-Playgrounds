//: # Crustacean
//:
//: Enum-Oriented Programming with Value Types
import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
//: Currently required for recursive enums, but will be fixed soon!
class Box<T> {
  let unbox: T
  init(_ value: T) { self.unbox = value }
}
//: Now a `Diagram`, which is an enum containing `Shape`s and `Diagram`s
enum Diagram {
  case Polygon(corners: [CGPoint])
  case Circle(center: CGPoint, radius: CGFloat)
  case Scale(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Diagrams(diagrams: Box<[Diagram]>)
  
  // convenience functions to handle boxing of `Diagram`s
  static func diagrams(diagrams: [Diagram]) -> Diagram {
    return .Diagrams(diagrams: Box(diagrams))
  }

  static func diagram(diagram: Diagram) -> Diagram {
    return .Diagrams(diagrams: Box([diagram]))
  }
  
  static func scale(x x: CGFloat, y: CGFloat, diagram: Diagram) -> Diagram {
    return .Scale(x: x, y: y, diagram: Box(diagram))
  }
}
//: ## Extend CGContext
//:
//: A few simple wrapper functions for `CGContext`
extension CGContext {
  func moveTo(position: CGPoint) {
    CGContextMoveToPoint(self, position.x, position.y)
  }
  func lineTo(position: CGPoint) {
    CGContextAddLineToPoint(self, position.x, position.y)
  }
  func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
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
func drawDiagram(diagram: Diagram)(context: CGContext) -> () {
  switch diagram {
  case let .Polygon(corners):
    context.moveTo(corners.last!)
    for p in corners { context.lineTo(p) }
    
  case let .Circle(center, radius):
    context.arcAt(center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    
  case let .Scale(x, y, diagram):
    context.scale(x, y) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Diagrams(diagrams):
    for d in diagrams.unbox { drawDiagram(d)(context: context) }
  }
}
//: Infix operator for combining `Diagrams`
func +(d1:Diagram, d2:Diagram) -> Diagram {
  return .diagrams([d1, d2])
}
//: ## Make some shapes
let circle = Diagram.Circle(center: CGPoint(x: 187.5, y: 333.5), radius: 93.75)

let triangle = Diagram.Polygon(corners: [
  CGPoint(x: 187.5, y: 427.25),
  CGPoint(x: 268.69, y: 286.625),
  CGPoint(x: 106.31, y: 286.625)])

let shape = circle + triangle
let diagram = shape + .scale(x: 0.3, y: 0.3, diagram: shape)

// Show the diagram in the view. To see the result, View>Assistant
// Editor>Show Assistant Editor (opt-cmd-Return).
showCoreGraphicsDiagram("Diagram") { drawDiagram(diagram)(context: $0) }

//: ## [Next](@next)
