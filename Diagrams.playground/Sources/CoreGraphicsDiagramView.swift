import UIKit
import PlaygroundSupport

/// `CoreGraphicsDiagramView` is a `UIView` that draws itself by calling a
/// user-supplied function to generate paths in a `CGContext`, then strokes
/// the context's current path, creating lines in a pleasing shade of blue.
class CoreGraphicsDiagramView : UIView {
  override func draw(_ rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      context.saveGState()
      let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: frame.height)
      context.concatenate(flipVertical)
      context.translateBy(x: frame.width/2, y: frame.height/2)
      
      draw(context)
      
      let lightBlue = UIColor(red: 0.222, green: 0.617, blue: 0.976, alpha: 1.0).cgColor
      context.setStrokeColor(lightBlue)
      context.setLineWidth(2)
      context.strokePath()
      context.restoreGState()
    }
  }
  
  var draw: (CGContext)->() = { _ in () }
}

/// Shows a `UIView` in the current playground that draws itself by invoking
/// `draw` on a `CGContext`, then stroking the context's current path in a
/// pleasing light blue.
public func showCoreGraphicsDiagram(size: CGSize, draw: @escaping (CGContext)->()) {
  let diagramView = CoreGraphicsDiagramView(frame: CGRect(origin: .zero, size: size))
  diagramView.draw = draw
  diagramView.setNeedsDisplay()
  PlaygroundPage.current.liveView = diagramView
}

public func displayDiagram(_ diagram: Diagram) {
  showCoreGraphicsDiagram(size: CGSize(width: 600, height: 600)) {
    drawDiagram(diagram, context: $0)
  }
}
