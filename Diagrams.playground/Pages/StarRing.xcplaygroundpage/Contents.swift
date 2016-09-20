//: Take a look in the `Sources` folder to see the implementation of **Diagram** and the **CGContext** extension.

import CoreGraphics

extension Diagram {
  func ring(radius: CGFloat, number: Int) -> Diagram {
    let angles = stride(from: 0.0, to: 360.0, by: 360.0/Double(number))
    return diagrams(angles.map {
      translate(x: 0, y: radius).rotate(CGFloat($0))
      }
    )
  }
  
  func iterateScale(_ s: CGFloat, iterate: Int) -> Diagram {
    if iterate == 0 { return self }
    return self + scale(s).iterateScale(s, iterate: iterate - 1)
  }
}

let star = polygon(
  [(0, 50), (10, 20), (40, 20), (20,  0),(30, -30), (0, -10),
   (-30, -30), (-20, 0), (-40, 20), (-10, 20), (0, 50)]
)

let starRing = star.ring(radius: 185, number: 16)
let diagram = starRing.iterateScale(0.74, iterate: 6)

showCoreGraphicsDiagram(size: CGSize(width: 600, height: 500)) {
  drawDiagram(diagram, context: $0)
}
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

[**Next ->**](@next)
*/
