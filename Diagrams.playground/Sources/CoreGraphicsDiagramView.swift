import UIKit
import XCPlayground

/// `CoreGraphicsDiagramView` is a `UIView` that draws itself by calling a
/// user-supplied function to generate paths in a `CGContext`, then strokes
/// the context's current path, creating lines in a pleasing shade of blue.
class CoreGraphicsDiagramView : UIView {
  override func drawRect(rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      CGContextSaveGState(context)
      let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, frame.height)
      CGContextConcatCTM(context, flipVertical);
      CGContextTranslateCTM(context, frame.width/2, frame.height/2)
      
      draw(context)
      
      let lightBlue = UIColor(red: 0.222, green: 0.617, blue: 0.976, alpha: 1.0).CGColor
      CGContextSetStrokeColorWithColor(context, lightBlue)
      CGContextSetLineWidth(context, 2)
      CGContextStrokePath(context)
      CGContextRestoreGState(context)
    }
  }
  
  var draw: (CGContext)->() = { _ in () }
}

/// Shows a `UIView` in the current playground that draws itself by invoking
/// `draw` on a `CGContext`, then stroking the context's current path in a
/// pleasing light blue.
public func showCoreGraphicsDiagram(size size: CGSize, draw: (CGContext)->()) {
  let diagramView = CoreGraphicsDiagramView(frame: CGRect(origin: CGPointZero, size: size))
  diagramView.draw = draw
  diagramView.setNeedsDisplay()
  XCPlaygroundPage.currentPage.liveView = diagramView
}
