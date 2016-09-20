import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
let toRadians = { $0 * CGFloat(M_PI / 180) }

public typealias Point = (x: CGFloat, y: CGFloat)

//: A `Diagram` as a recursive enum
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

// convenience methods to allow chaining of transformations
public extension Diagram {
  func scale(_ s: CGFloat) -> Diagram {
    return .Scale(x: s, y: s, diagram: self)
  }
  
  func scale(x: CGFloat, y: CGFloat) -> Diagram {
    return .Scale(x: x, y: y, diagram: self)
  }
  
  func translate(x: CGFloat, y: CGFloat) -> Diagram {
    return .Translate(x: x, y: y, diagram: self)
  }
  
  func rotate(_ x: CGFloat) -> Diagram {
    return .Rotate(angle: x, diagram: self)
  }
}

// convenience functions to handle conversion from `Point` to `CGPoint`
// (defining an Array of `CGpoint`s is really verbose – hence the use of the `tuple` typealias `Point`)
public func line(ps: [Point]) -> Diagram {
  return .Line(ps.map { x, y in CGPoint(x: x, y: y) })
}

public func polygon(_ ps: [Point]) -> Diagram {
  return .Polygon(ps.map { x, y in CGPoint(x: x, y: y) })
}

public func rectanglePath(width: CGFloat, height: CGFloat) -> [Point] {
  let sx = width / 2
  let sy = height / 2
  return [(-sx, -sy), (-sx, sy), (sx, sy), (sx, -sy)]
}

public func rectangle(x: CGFloat, _ y: CGFloat) -> Diagram {
  return polygon(rectanglePath(width: x, height: y))
}

public func circle(_ radius: CGFloat) -> Diagram {
  return .Circle(radius: radius)
}

public func diagrams(_ diagrams: [Diagram]) -> Diagram {
  return .Diagrams(diagrams)
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
    return lx == rx && ly == ry && lDiagram == rDiagram
    
  case let (.Translate(lx, ly, lDiagram), .Translate(rx, ry, rDiagram)):
    return lx == rx && ly == ry && lDiagram == rDiagram
    
  case let (.Rotate(la, lDiagram), .Rotate(ra, rDiagram)):
    return la == ra && lDiagram == rDiagram
    
  case let (.Diagrams(lDiagrams), .Diagrams(rDiagrams)):
    let (l, r) = (lDiagrams, rDiagrams)
    return l.count == r.count && !zip(l, r).contains { $0 != $1 }
    
  default: return false
  }
}

//: Infix operator for combining Diagrams
public func + (d1: Diagram, d2: Diagram) -> Diagram {
  return diagrams([d1, d2])
}

//: ## Do some drawing!
//:
//: A recursive function responsible for drawing a diagram into a CGContext
public func drawDiagram(_ diagram: Diagram, context: CGContext) -> () {
  switch diagram {
  case let .Polygon(corners):
    context.drawPolygon(corners)
    
  case let .Line(points):
    context.drawPath(points)
 
  case let .Arc(r, a1, a2):
    context.arc(radius: r, startAngle: toRadians(a1), endAngle: toRadians(a2))
    
  case let .Circle(radius):
    context.circle(radius: radius)

  case let .Scale(x, y, diagram):
    context.scale(x: x, y: y) {
      drawDiagram(diagram, context: $0)
    }
    
  case let .Translate(x, y, diagram):
    context.translate(x: x, y: y) {
      drawDiagram(diagram, context: $0)
    }
    
  case let .Rotate(angle, diagram):
    context.rotate(angle: toRadians(angle)) {
      drawDiagram(diagram, context: $0)
    }
    
  case let .Diagrams(diagrams):
    diagrams.forEach { d in drawDiagram(d, context: context) }
  }
}
