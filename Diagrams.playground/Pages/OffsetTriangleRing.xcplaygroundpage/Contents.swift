/*:
[**<- Previous**](@previous)
*/
import CoreGraphics

func ring(radius radius: CGFloat, number: Int, _ diagram: Diagram) -> Diagram {
  let angles = stride(from: 0.0, to: 360.0, by: 360.0/Double(number))
  return diagrams(angles.map {
    rotate(angle: CGFloat($0), translate(x: 0, y: radius, diagram))
    })
}

func iterateScale(s: CGFloat, offset: Point = (0,0), iterate: Int, _ diagram: Diagram) -> Diagram {
  if iterate == 0 { return diagram }
  return iterateScale(s, offset: offset, iterate: iterate - 1,
    diagram + translate(x: CGFloat(offset.0), y: CGFloat(offset.1), scale(x: s, y: s, diagram)))
}

let triangle = polygon( [(0, -25), (25, 0), (-25, 0)])

let triangleRing = ring(radius: 220, number: 27, triangle)
let diagram = iterateScale(0.618, offset: (15, 30), iterate: 8, triangleRing)

showCoreGraphicsDiagram("Diagram", size: CGSize(width: 600, height: 500)) {
  drawDiagram(diagram)(context: $0)
}
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

[**Next ->**](@next)
*/
