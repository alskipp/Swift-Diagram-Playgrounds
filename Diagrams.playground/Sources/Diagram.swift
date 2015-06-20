import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
let toDegrees: CGFloat -> CGFloat = { CGFloat(M_PI / 180) * $0 }

public typealias Point = (x: Double, y: Double)
public typealias Size = (width: Double, height: Double)

//: Currently required for recursive enums, but will be fixed soon!
public class Box<T> {
  public let unbox: T
  init(_ value: T) { self.unbox = value }
}
//: A `Diagram` as a recursive enum
public enum Diagram {
  case Polygon(corners: [CGPoint])
  case Line(points: [CGPoint])
  case Circle(center: CGPoint, radius: CGFloat)
  case Scale(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Translate(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Rotate(angle: CGFloat, diagram: Box<Diagram>)
  case Diagrams(diagrams: Box<[Diagram]>)
}

// convenience functions to handle conversion from `Point` to `CGPoint`
// (defining an Array of `CGpoint`s is really verbose – hence the use of the `tuple` typealias `Point`)
public func line(ps: [Point]) -> Diagram {
  return .Line(points: ps.map { x, y in CGPoint(x: x, y: y) })
}

public func polygon(ps: [Point]) -> Diagram {
  return .Polygon(corners: ps.map { x, y in CGPoint(x: x, y: y) })
}

public func rectanglePath(width: Double, _ height: Double) -> [Point] {
  let sx = width / 2
  let sy = height / 2
  return [(-sx, -sy), (-sx, sy), (sx, sy), (sx, -sy)]
}

public func rectangle(size: Size) -> Diagram {
  return polygon(rectanglePath(size.0, size.1))
}
// convenience functions to handle boxing of `Diagram`s
public func diagrams(diagrams: [Diagram]) -> Diagram {
  return .Diagrams(diagrams: Box(diagrams))
}

public func diagram(diagram: Diagram) -> Diagram {
  return .Diagrams(diagrams: Box([diagram]))
}

public func scale(x x: CGFloat, y: CGFloat, _ diagram: Diagram) -> Diagram {
  return .Scale(x: x, y: y, diagram: Box(diagram))
}

public func translate(x x: CGFloat, y: CGFloat, _ diagram: Diagram) -> Diagram {
  return .Translate(x: x, y: y, diagram: Box(diagram))
}

public func rotate(angle x: CGFloat, _ diagram: Diagram) -> Diagram {
  return .Rotate(angle: x, diagram: Box(diagram))
}

extension Diagram: Equatable { }
public func == (lhs: Diagram, rhs: Diagram) -> Bool {
  switch (lhs, rhs) {
  case let (.Polygon(l), .Polygon(r)):
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  case let (.Line(l), .Line(r)):
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  case let (.Circle(lCenter, lRadius), .Circle(rCenter, rRadius)):
    return lCenter == rCenter && lRadius == rRadius
    
  case let (.Scale(lx, ly, lDiagram), .Scale(rx, ry, rDiagram)):
    return lx == rx && ly == ry && lDiagram.unbox == rDiagram.unbox
    
  case let (.Translate(lx, ly, lDiagram), .Translate(rx, ry, rDiagram)):
    return lx == rx && ly == ry && lDiagram.unbox == rDiagram.unbox
    
  case let (.Rotate(la, lDiagram), .Rotate(ra, rDiagram)):
    return la == ra && lDiagram.unbox == rDiagram.unbox
    
  case let (.Diagrams(lDiagrams), .Diagrams(rDiagrams)):
    let (l, r) = (lDiagrams.unbox, rDiagrams.unbox)
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  default: return false
  }
}

//: Infix operator for combining Diagrams
public func +(d1:Diagram, d2:Diagram) -> Diagram {
  return diagrams([d1, d2])
}

//: ## Do some drawing!
//:
//: A recursive function responsible for drawing a diagram into a CGContext
public func drawDiagram(diagram: Diagram)(context: CGContext) -> () {
  switch diagram {
  case let .Polygon(corners):
    context.drawPolygon(corners)
    
  case let .Line(points):
    context.drawPath(points)
    
  case let .Circle(center, radius):
    context.circleAt(center, radius: radius)
    
  case let .Scale(x, y, diagram):
    context.scale(x, y) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Translate(x, y, diagram):
    context.translate(x, y) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Rotate(angle, diagram):
    context.rotate(toDegrees(angle)) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Diagrams(diagrams):
    diagrams.unbox.map { d in drawDiagram(d)(context: context) }
  }
}

