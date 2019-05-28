//
//  MZRRotator.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/26.
//

class MZRRotator: MZRItem {
    
    var radius = CGFloat(8)
    
    weak var targetItem: MZRItem? {
        didSet {
            guard let item = targetItem, let anchorPoint = item.anchorPoint() else { return }
            modifyPoint(anchorPoint, at: (0, 0))
        }
    }
    
    // MARK: - Life Cycle
    
    required init() {
        fatalError("Use init(target:) instead.")
    }
    
    init(target: MZRItem) {
        super.init(.std(1, 1))
        targetItem = target
        color = MZRMakeCGColor(r: 1, g: 0, b: 0, a: 1)
        addPoint(.zero)
    }
    
    // MARK: - Edit
    
    override func modifyPoint(_ point: CGPoint, at position: MZRItem.Position) {
        if let targetItem = targetItem {
            let targetItemPoints = targetItem.points.flatMap({ $0 })
            
            let currentCircle = Circle(center: points[position.0][position.1], radius: radius)
            let sticked = targetItemPoints.contains(where: { currentCircle.contains($0) })
            
            let nextCircle = Circle(center: point, radius: radius)
            let near = targetItemPoints.contains(where: { nextCircle.contains($0) })
            
            if near {
                if !sticked {
                    for (col, section) in targetItem.points.enumerated() {
                        for (row, point) in section.enumerated() {
                            if nextCircle.contains(point) {
                                targetItem.rotationAnchor = .position((col, row))
                                super.modifyPoint(point, at: (0, 0))
                                return
                            }
                        }
                    }
                }
                return
            }
            
            targetItem.rotationAnchor = .point(point)
            super.modifyPoint(point, at: position)
        }
    }
    
    func forceModifyPoint(_ point: CGPoint, at position: MZRItem.Position) {
        points[position.0][position.1] = point
    }
    
    // MARK: - Drawing
    
    override func drawPoints(marked: [MZRItem.Position]? = nil) {
        guard let context = CGContext.current else { return }
        let circle = Circle(center: points[0][0], radius: 1)
        context.saveGState()
        defer { context.restoreGState() }
        context.setFillColor(color)
        circle.fill()
    }
    
    override func draw() {
        guard let context = CGContext.current, let item = targetItem else { return }
        let center = points[0][0]
        context.saveGState()
        defer { context.restoreGState() }
        context.setStrokeColor(color)
        Circle(center: center, radius: radius).stroke()
        let len = radius * 1.5
        let vertical = Line(from: center.extended(length: len, angle: .pi / 2 + item.rotation),
                            to: center.extended(length: len, angle: -.pi / 2 + item.rotation))
        let horizontal = Line(from: center.extended(length: len, angle: item.rotation),
                              to: center.extended(length: len, angle: .pi + item.rotation))
        vertical.stroke()
        horizontal.stroke()
    }
    
    func contains(_ location: CGPoint) -> Bool {
        let center = points[0][0]
        let circle = Circle(center: center, radius: radius)
        return circle.contains(location)
    }
    
}
