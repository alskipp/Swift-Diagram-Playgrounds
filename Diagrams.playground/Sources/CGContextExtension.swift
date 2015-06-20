import CoreGraphics

public extension CGContext {
  func moveTo(position: CGPoint) {
    CGContextMoveToPoint(self, position.x, position.y)
  }
  func lineTo(position: CGPoint) {
    CGContextAddLineToPoint(self, position.x, position.y)
  }
  func drawPath(points: [CGPoint]) {
    points.first.map(moveTo)
    points.map(lineTo)
  }
  func drawPolygon(points: [CGPoint]) {
    points.last.map(moveTo)
    points.map(lineTo)
  }
  func arc(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
    let arc = CGPathCreateMutable()
    CGPathAddArc(arc, nil, 0, 0, radius, startAngle, endAngle, false)
    CGContextAddPath(self, arc)
  }
  func circle(radius: CGFloat) {
    arc(radius, startAngle: 0.0, endAngle: twoPi)
  }
  func saveContext(operation: () -> ()) {
    CGContextSaveGState(self)
    operation()
    CGContextRestoreGState(self)
  }
  func scale(x: CGFloat, _ y: CGFloat, operation: CGContext -> ()) {
    saveContext {
      CGContextScaleCTM(self, x, y)
      operation(self)
    }
  }
  func translate(x: CGFloat, _ y: CGFloat, operation: CGContext -> ()) {
    saveContext {
      CGContextTranslateCTM(self, x, y)
      operation(self)
    }
  }
  func rotate(angle: CGFloat, operation: CGContext -> ()) {
    saveContext {
      CGContextRotateCTM(self, angle)
      operation(self)
    }
  }
}