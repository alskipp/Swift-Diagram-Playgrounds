//: Take a look in the `Sources` folder to see the implementation of **Diagram** and the **CGContext** extension.

import CoreGraphics

func ring(radius radius: CGFloat, number: Int, _ diagram: Diagram) -> Diagram {
  let angles = stride(from: 0.0, to: 360.0, by: 360.0/Double(number))
  return diagrams(angles.map {
    rotate(angle: CGFloat($0), translate(x: 0, y: radius, diagram))
  })
}

func iterateScale(s: CGFloat, iterate: Int, _ diagram: Diagram) -> Diagram {
  if iterate == 0 { return diagram }
  return iterateScale(s, iterate: iterate - 1, diagram + scale(x: s, y: s, diagram))
}

let star = polygon(
  [(0, 50), (10, 20), (40, 20), (20,  0),(30, -30), (0, -10),
   (-30, -30), (-20, 0), (-40, 20), (-10, 20), (0, 50)]
)

let starRing = ring(radius: 185, number: 12, star)
let diagram = iterateScale(0.67, iterate: 6, starRing)

showCoreGraphicsDiagram("Diagram", size: CGSize(width: 600, height: 500)) {
  drawDiagram(diagram)(context: $0)
}
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

[**Next ->**](@next)
*/
