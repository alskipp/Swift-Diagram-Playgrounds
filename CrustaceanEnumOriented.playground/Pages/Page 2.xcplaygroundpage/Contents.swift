//: # Crustacean II
//:
//: Enum-Oriented Programming with Value Types
import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
//: Currently required for recursive enums, but will be fixed soon!
class Box<T> {
  let unbox: T
  init(_ value: T) { self.unbox = value }
}
//: A `Diagram` as a recursive enum
enum Diagram {
  case Polygon(corners: [CGPoint])
  case Circle(center: CGPoint, radius: CGFloat)
  case Rectangle(bounds: CGRect)
  case Scale(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Translate(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
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
  
  static func translate(x x: CGFloat, y: CGFloat, diagram: Diagram) -> Diagram {
    return .Translate(x: x, y: y, diagram: Box(diagram))
  }
}

extension Diagram: Equatable { }
func == (lhs: Diagram, rhs: Diagram) -> Bool {
  switch (lhs, rhs) {
  case let (.Polygon(l), .Polygon(r)):
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  case let (.Circle(lCenter, lRadius), .Circle(rCenter, rRadius)):
    return lCenter == rCenter && lRadius == rRadius
    
  case let (.Rectangle(lBounds), .Rectangle(rBounds)):
    return lBounds == rBounds
  
  case let (.Scale(lx, ly, lDiagram), .Scale(rx, ry, rDiagram)):
    return lx == rx && ly == ry && lDiagram.unbox == rDiagram.unbox

  case let (.Translate(lx, ly, lDiagram), .Translate(rx, ry, rDiagram)):
    return lx == rx && ly == ry && lDiagram.unbox == rDiagram.unbox
    
  case let (.Diagrams(lDiagrams), .Diagrams(rDiagrams)):
    let (l, r) = (lDiagrams.unbox, rDiagrams.unbox)
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  default: return false
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
  func circleAt(center: CGPoint, radius: CGFloat) {
    arcAt(center, radius: radius, startAngle: 0.0, endAngle: twoPi)
  }
  func rectangleAt(r: CGRect) {
    CGContextAddRect(self, r)
  }
  func scale(x: CGFloat, _ y: CGFloat, operation: CGContext -> ()) {
    CGContextSaveGState(self)
    CGContextScaleCTM(self, x, y)
    operation(self)
    CGContextRestoreGState(self)
  }
  func translate(x: CGFloat, _ y: CGFloat, operation: CGContext -> ()) {
    CGContextSaveGState(self)
    CGContextTranslateCTM(self, x, y)
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

  case let .Rectangle(bounds):
    context.rectangleAt(bounds)
    
  case let .Scale(x, y, diagram):
    context.scale(x, y) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Translate(x, y, diagram):
    context.translate(x, y) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Diagrams(diagrams):
    for d in diagrams.unbox { drawDiagram(d)(context: context) }
  }
}
//: Infix operator for combining Diagrams
func +(d1:Diagram, d2:Diagram) -> Diagram {
  return .diagrams([d1, d2])
}
//: A bubble is made of an outer circle and an inner highlight
func bubble(center: CGPoint, radius: CGFloat) -> Diagram {
  let circle = Diagram.Circle(center: center, radius: radius)
  let pos = CGPoint(x: center.x + 0.2 * radius, y: center.y - 0.4 * radius)
  let highlight = Diagram.Circle(center: pos, radius: radius * 0.33)
  return .diagrams([circle, highlight])
}
//: Return a regular `n`-sided polygon with corners on a circle
//: having the given `center` and `radius`
func regularPolygon(n: Int, center: CGPoint, radius r: CGFloat) -> Diagram {
  let angles = (0..<n).map { twoPi / CGFloat(n) * CGFloat($0) }
  return .Polygon(corners: angles.map {
    CGPoint(x: center.x + sin($0) * r, y: center.y + cos($0) * r)
    })
}
//: Returns a diagram in the center of the given frame containing an
//: equilateral triangle inscribed in a circle.
func sampleDiagram(frame: CGRect) -> Diagram {
  let r = min(frame.width, frame.height) / 4
  let center = CGPoint(x: frame.midX, y: frame.midY)
  
  let circle = Diagram.Circle(center: center, radius: r)
  let poly = regularPolygon(3, center: center, radius: r)
  
  let sq = CGRect(x: center.x - r/3, y: center.y, width: r/6, height: r/6)
  let rect = Diagram.Rectangle(bounds: sq)

  let offsetCirc = Diagram.translate(x: 0, y: r * 2.5, diagram: circle)
  
  return .diagrams([circle, poly, rect, offsetCirc])
}

let drawingArea = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)

// A closure that returns a Bubble
let makeBubble: () -> Diagram = {
  let radius = drawingArea.width / 10
  let margin = radius * 1.2
  let center = CGPoint(x: drawingArea.maxX - margin, y: drawingArea.minY + margin)
  return bubble(center, radius: radius)
}
//: Create a simple diagram
let sample = sampleDiagram(drawingArea)
let diagram = sample + .scale(x: 0.3, y: 0.3, diagram: sample) + makeBubble()

// Show the diagram in the view. To see the result, View>Assistant
// Editor>Show Assistant Editor (opt-cmd-Return).
showCoreGraphicsDiagram("Diagram") { drawDiagram(diagram)(context: $0) }
