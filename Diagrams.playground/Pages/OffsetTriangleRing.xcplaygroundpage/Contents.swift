/*:
[**<- Previous**](@previous)
*/
import CoreGraphics

extension Diagram {
  func ring(radius: CGFloat, number: Int) -> Diagram {
    let angles = stride(from: 0.0, to: 360.0, by: 360.0/Double(number))
    return diagrams(angles.map {
      translate(x: 0, y: radius).rotate(CGFloat($0))
      }
    )
  }
  
  func iterateScale(_ s: CGFloat, offset: Point = (0,0), iterate: Int) -> Diagram {
    if iterate == 0 { return self }
    return self + scale(s)
      .translate(x: offset.x, y: offset.y)
      .iterateScale(s, offset: offset, iterate: iterate - 1)
  }
}

let triangle = polygon([(0, -50), (25, 0), (-25, 0)])

let triangleRing = triangle.ring(radius: 220, number: 27)
let diagram = triangleRing.iterateScale(0.618, offset: (15, 30), iterate: 7)

showCoreGraphicsDiagram(size: CGSize(width: 600, height: 500)) {
  drawDiagram(diagram, context: $0)
}
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

[**Next ->**](@next)
*/
