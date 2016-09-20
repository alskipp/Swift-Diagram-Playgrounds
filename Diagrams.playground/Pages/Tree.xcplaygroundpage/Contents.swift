/*: 
[**<- Previous**](@previous)

## I want to be a tree
*/
extension Diagram {
  func tree(_ n: Int) -> Diagram {
    if n == 0 { return self }
    
    let smallTree = tree(n - 1).scale(x: 0.6, y: 0.67)
    
    return diagrams([
      stump,
      smallTree.translate(x: 0, y: 190),
      smallTree.rotate(35).translate(x: 0, y: 200),
      smallTree.rotate(-35).translate(x: 0, y: 180)
      ])
  }
}

let stump = polygon([(30, 0), (10, 300), (-10, 300), (-30, 0)])
let aTree = stump.tree(5).translate(x: 0, y: -260)

displayDiagram(aTree)
/*:
To see the result, View>Assistant Editor>Show Assistant Editor (opt-cmd-Return).

* * *

Inspired by the *tree* example in the Haskell library [**Gloss**](https://github.com/benl23x5/gloss)

* * *

With a few tweeks we can create a different looking tree: [**Next ->**](@next)
*/
