//: # Crustacean II
//:
//: Enum-Oriented Programming with Value Types
import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
//: A `Diagram` as a recursive enum
enum Diagram {
  case polygon(corners: [CGPoint])
  case circle(center: CGPoint, radius: CGFloat)
  case rectangle(CGRect)
  indirect case scale(x: CGFloat, y: CGFloat, diagram: Diagram)
  indirect case translate(x: CGFloat, y: CGFloat, diagram: Diagram)
  case diagrams([Diagram])
}

extension Diagram: Equatable { }
func == (lhs: Diagram, rhs: Diagram) -> Bool {
  switch (lhs, rhs) {
  case let (.polygon(l), .polygon(r)):
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  case let (.circle(lCenter, lRadius), .circle(rCenter, rRadius)):
    return lCenter == rCenter && lRadius == rRadius
    
  case let (.rectangle(lBounds), .rectangle(rBounds)):
    return lBounds == rBounds
  
  case let (.scale(lx, ly, lDiagram), .scale(rx, ry, rDiagram)):
    return lx == rx && ly == ry && lDiagram == rDiagram

  case let (.translate(lx, ly, lDiagram), .translate(rx, ry, rDiagram)):
    return lx == rx && ly == ry && lDiagram == rDiagram
    
  case let (.diagrams(lDiagrams), .diagrams(rDiagrams)):
    let (l, r) = (lDiagrams, rDiagrams)
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  default: return false
  }
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
  func circleAt(center: CGPoint, radius: CGFloat) {
    addArc(center: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
  }
  func translate(x: CGFloat, y: CGFloat, operation: (CGContext) -> ()) {
    saveGState()
    translateBy(x: x, y: y)
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
    context.circleAt(center: center, radius: radius)

  case let .rectangle(bounds):
    context.addRect(bounds)
    
  case let .scale(x, y, diagram):
    context.scale(x: x, y: y) {
      drawDiagram(diagram, context: $0)
    }
    
  case let .translate(x, y, diagram):
    context.translate(x: x, y: y) {
      drawDiagram(diagram, context: $0)
    }
    
  case let .diagrams(diagrams):
    for d in diagrams { drawDiagram(d, context: context) }
  }
}
//: Infix operator for combining Diagrams
func + (d1: Diagram, d2: Diagram) -> Diagram {
  return .diagrams([d1, d2])
}
//: A bubble is made of an outer circle and an inner highlight
func bubble(center: CGPoint, radius: CGFloat) -> Diagram {
  let circle = Diagram.circle(center: center, radius: radius)
  let pos = CGPoint(x: center.x + 0.2 * radius, y: center.y - 0.4 * radius)
  let highlight = Diagram.circle(center: pos, radius: radius * 0.33)
  return .diagrams([circle, highlight])
}
//: Return a regular `n`-sided polygon with corners on a circle
//: having the given `center` and `radius`
func regularPolygon(sides n: Int, center: CGPoint, radius r: CGFloat) -> Diagram {
  let angles = (0..<n).map { twoPi / CGFloat(n) * CGFloat($0) }
  return .polygon(corners: angles.map {
    CGPoint(x: center.x + sin($0) * r, y: center.y + cos($0) * r)
    })
}
//: Returns a diagram in the center of the given frame containing an
//: equilateral triangle inscribed in a circle.
func sampleDiagram(frame: CGRect) -> Diagram {
  let r = min(frame.width, frame.height) / 4
  let center = CGPoint(x: frame.midX, y: frame.midY)
  
  let circle = Diagram.circle(center: center, radius: r)
  let poly = regularPolygon(sides: 3, center: center, radius: r)
  
  let sq = CGRect(x: center.x - r/3, y: center.y, width: r/6, height: r/6)
  let rect = Diagram.rectangle(sq)

  let offsetCirc = Diagram.translate(x: 0, y: r * 2.5, diagram: circle)
  
  return .diagrams([circle, poly, rect, offsetCirc])
}

let drawingArea = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)

// A closure that returns a Bubble
let makeBubble: () -> Diagram = {
  let radius = drawingArea.width / 10
  let margin = radius * 1.2
  let center = CGPoint(x: drawingArea.maxX - margin, y: drawingArea.minY + margin)
  return bubble(center: center, radius: radius)
}
//: Create a simple diagram
let sample = sampleDiagram(frame: drawingArea)
let diagram = sample + .scale(x: 0.3, y: 0.3, diagram: sample) + makeBubble()

// Show the diagram in the view. To see the result, View>Assistant
// Editor>Show Assistant Editor (opt-cmd-Return).
showCoreGraphicsDiagram { drawDiagram(diagram, context: $0) }
