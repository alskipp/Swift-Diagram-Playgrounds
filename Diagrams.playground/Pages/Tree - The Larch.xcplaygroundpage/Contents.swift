/*:
[**<- Previous**](@previous)

## The Larch
*/
extension Diagram {
  func tree(_ n: Int) -> Diagram {
    if n == 0 { return self }
    
    let smallTree = tree(n - 1).scale(x: 0.33, y: 0.45)
    
    return diagrams([
      stump,
      smallTree.translate(x: 0, y: 300),
      smallTree.rotate(45).translate(x: -8, y: 250),
      smallTree.rotate(-45).translate(x: 12, y: 200),
      smallTree.rotate(70).translate(x: -18, y: 150),
      smallTree.rotate(-70).translate(x: 22, y: 100)
      ])
  }
}

let stump = polygon([(30, 0), (10, 300), (-10, 300), (-30, 0)])
let larchTree = stump.tree(5).translate(x: 0, y: -260)

displayDiagram(larchTree)
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

*/
