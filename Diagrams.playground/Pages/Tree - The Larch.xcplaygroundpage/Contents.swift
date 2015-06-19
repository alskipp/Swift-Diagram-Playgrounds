/*:
[**<- Previous**](@previous)

## The Larch
*/
import CoreGraphics

func displayDiagram(diagram: Diagram) {
  showCoreGraphicsDiagram("Diagram", size: CGSize(width: 600, height: 600)) {
    drawDiagram(diagram)(context: $0)
  }
}

let stump = polygon([(30, 0), (10, 300), (-10, 300), (-30, 0)])

func tree(n: Int) -> Diagram {
  if n == 0 { return stump }
  
  let smallTree = scale(x: 0.33, y: 0.45, tree(n - 1))
  
  return diagrams([
    stump,
    translate(x: 0, y: 300, smallTree),
    translate(x: -8, y: 250, rotate(angle: 45, smallTree)),
    translate(x: 12, y: 200, rotate(angle: -45, smallTree)),
    translate(x: -18, y: 150, rotate(angle: 70, smallTree)),
    translate(x: 22, y: 100, rotate(angle: -70, smallTree)),
    ])
}

let growTree = { translate(x: 0, y: -260, tree(4)) }

displayDiagram(growTree())
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

*/
