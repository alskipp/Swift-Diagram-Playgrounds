import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
let toRadians = { $0 * CGFloat(M_PI / 180) }

public typealias Point = (x: CGFloat, y: CGFloat)

//: Currently required for recursive enums, but will be fixed soon!
public class Box<T> {
  public let unbox: T
  init(_ value: T) { self.unbox = value }
}
//: A `Diagram` as a recursive enum
public enum Diagram {
  case Polygon(corners: [CGPoint])
  case Line(points: [CGPoint])
  case Arc(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
  case Circle(radius: CGFloat)
  case Scale(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Translate(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Rotate(angle: CGFloat, diagram: Box<Diagram>)
  case Diagrams(diagrams: Box<[Diagram]>)
}

// convenience methods to handle boxing of `Diagram`s and allow chaining of transformations
public extension Diagram {
  func scale(s: CGFloat) -> Diagram {
    return .Scale(x: s, y: s, diagram: Box(self))
  }
  
  func scale(x x: CGFloat, y: CGFloat) -> Diagram {
    return .Scale(x: x, y: y, diagram: Box(self))
  }
  
  func translate(x x: CGFloat, y: CGFloat) -> Diagram {
    return .Translate(x: x, y: y, diagram: Box(self))
  }
  
  func rotate(x: CGFloat) -> Diagram {
    return .Rotate(angle: x, diagram: Box(self))
  }
}

// convenience functions to handle conversion from `Point` to `CGPoint`
// (defining an Array of `CGpoint`s is really verbose – hence the use of the `tuple` typealias `Point`)
public func line(ps: [Point]) -> Diagram {
  return .Line(points: ps.map { x, y in CGPoint(x: x, y: y) })
}

public func polygon(ps: [Point]) -> Diagram {
  return .Polygon(corners: ps.map { x, y in CGPoint(x: x, y: y) })
}

public func rectanglePath(width: CGFloat, _ height: CGFloat) -> [Point] {
  let sx = width / 2
  let sy = height / 2
  return [(-sx, -sy), (-sx, sy), (sx, sy), (sx, -sy)]
}

public func rectangle(x: CGFloat, _ y: CGFloat) -> Diagram {
  return polygon(rectanglePath(x, y))
}

public func circle(radius: CGFloat) -> Diagram {
  return .Circle(radius: radius)
}

public func diagrams(diagrams: [Diagram]) -> Diagram {
  return .Diagrams(diagrams: Box(diagrams))
}


extension Diagram: Equatable { }
public func == (lhs: Diagram, rhs: Diagram) -> Bool {
  switch (lhs, rhs) {
  case let (.Polygon(l), .Polygon(r)):
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  case let (.Line(l), .Line(r)):
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }

  case let (.Arc(lRadius, la1, la2), .Arc(rRadius, ra1, ra2)):
    return lRadius == rRadius && la1 == ra1 && la2 == ra2
    
  case let (.Circle(lRadius), .Circle(rRadius)):
    return lRadius == rRadius
    
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
public func + (d1:Diagram, d2:Diagram) -> Diagram {
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
 
  case let .Arc(r, a1, a2):
    context.arc(r, startAngle: toRadians(a1), endAngle: toRadians(a2))
    
  case let .Circle(radius):
    context.circle(radius)
    
  case let .Scale(x, y, diagram):
    context.scale(x, y) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Translate(x, y, diagram):
    context.translate(x, y) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Rotate(angle, diagram):
    context.rotate(toRadians(angle)) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Diagrams(diagrams):
    diagrams.unbox.map { d in drawDiagram(d)(context: context) }
  }
}

