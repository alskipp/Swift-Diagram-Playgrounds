/*: 
[**<- Previous**](@previous)

## I want to be a tree
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
  
  let smallTree = scale(x: 0.6, y: 0.67, tree(n - 1))

  return diagrams([
    stump,
    translate(x: 0, y: 190, smallTree),
    translate(x: 0, y: 200, rotate(35, smallTree)),
    translate(x: 0, y: 180, rotate(-35, smallTree)),
    ])
}

let growTree = { translate(x: 0, y: -260, tree(5)) }

displayDiagram(growTree())
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

Inspired by the *tree* example in the Haskell library [**Gloss**](https://github.com/benl23x5/gloss)

* * *

With a few tweeks we can create a different looking tree: [**Next ->**](@next)
*/
