import CoreGraphics
let twoPi = CGFloat(M_PI * 2)
let toDegrees: CGFloat -> CGFloat = { CGFloat(M_PI / 180) * $0 }

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
  case Rectangle(bounds: CGRect)
  case Scale(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Translate(x: CGFloat, y: CGFloat, diagram: Box<Diagram>)
  case Rotate(angle: CGFloat, diagram: Box<Diagram>)
  case Diagrams(diagrams: Box<[Diagram]>)
  
  // convenience functions to handle boxing of `Diagram`s
  public static func diagrams(diagrams: [Diagram]) -> Diagram {
    return .Diagrams(diagrams: Box(diagrams))
  }
  
  public static func diagram(diagram: Diagram) -> Diagram {
    return .Diagrams(diagrams: Box([diagram]))
  }
  
  public static func scale(x x: CGFloat, y: CGFloat, _ diagram: Diagram) -> Diagram {
    return .Scale(x: x, y: y, diagram: Box(diagram))
  }
  
  public static func translate(x x: CGFloat, y: CGFloat, _ diagram: Diagram) -> Diagram {
    return .Translate(x: x, y: y, diagram: Box(diagram))
  }
  
  public static func rotate(angle x: CGFloat, _ diagram: Diagram) -> Diagram {
    return .Rotate(angle: x, diagram: Box(diagram))
  }
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
    
  case let (.Rectangle(lBounds), .Rectangle(rBounds)):
    return lBounds == rBounds
    
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
  return .diagrams([d1, d2])
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
    
  case let .Rotate(angle, diagram):
    context.rotate(toDegrees(angle)) {
      drawDiagram(diagram.unbox)(context: $0)
    }
    
  case let .Diagrams(diagrams):
    diagrams.unbox.map { d in drawDiagram(d)(context: context) }
  }
}

