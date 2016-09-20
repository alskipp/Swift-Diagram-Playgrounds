import CoreGraphics

public extension CGContext {
  func drawPath(_ points: [CGPoint]) {
    if let p = points.first {
      move(to: p)
      points.forEach { addLine(to: $0) }
    }
  }
  func drawPolygon(_ points: [CGPoint]) {
    if let p = points.last {
      move(to: p)
      points.forEach { addLine(to: $0) }
    }
  }
  func arc(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
    let arc = CGMutablePath()
    arc.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    addPath(arc)
  }
  func circle(radius: CGFloat) {
    arc(radius: radius, startAngle: 0.0, endAngle: twoPi)
  }
  func saveContext(operation: () -> ()) {
    saveGState()
    operation()
    restoreGState()
  }
  func scale(x: CGFloat, y: CGFloat, operation: (CGContext) -> ()) {
    saveContext {
      scaleBy(x: x, y: y)
      operation(self)
    }
  }
  func translate(x: CGFloat, y: CGFloat, operation: (CGContext) -> ()) {
    saveContext {
      translateBy(x: x, y: y)
      operation(self)
    }
  }
  func rotate(angle: CGFloat, operation: (CGContext) -> ()) {
    saveContext {
      rotate(by: angle)
      operation(self)
    }
  }
}
