import CoreGraphics

let starPoints = [(0, 50), (10, 20), (40, 20), (20,  0),
  (30, -30), (0, -10), (-30, -30), (-20, 0), (-40, 20),
  (-10, 20), (0, 50)].map { x, y in CGPoint(x: x, y: y)
}

let star = Diagram.Polygon(corners: starPoints)

func diagramRing(diagram: Diagram, radius: CGFloat, number: Int) -> Diagram {
  let r = stride(from: CGFloat(0), to: CGFloat(360), by: CGFloat(360/number))
  return .diagrams(r.map {
    .rotate(angle: $0, .translate(x: 0, y: radius, diagram))
  })
}

let ring = diagramRing(star, radius: 185, number: 12)
let concentric = ring + .scale(x: 0.6, y: 0.6, ring) + .scale(x: 0.3, y: 0.3, ring)
let diagram = concentric + .scale(x: 0.15, y: 0.15, concentric)

showCoreGraphicsDiagram("Diagram", size: CGSize(width: 600, height: 500)) {
  drawDiagram(diagram)(context: $0)
}
