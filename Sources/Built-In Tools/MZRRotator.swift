//
//  MZRRotator.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/26.
//

class MZRRotator: MZRItem {
    
    weak var targetItem: MZRItem?
    
    var threshold = CGFloat(10)
    
    // MARK: - Life Cycle
    
    required init() {
        fatalError("Use init(item:) instead.")
    }
    
    init?(item: MZRItem) {
        guard let anchorPoint = item.anchorPoint(), item.isCompleted else { return nil }
        super.init(.std(1, 1))
        targetItem = item
        addPoint(anchorPoint)
    }
    
    // MARK: - Edit
    
    override func modifyPoint(_ point: CGPoint, at position: MZRItem.Position) {
        super.modifyPoint(point, at: position)
    }
    
    // MARK: - Targeting
    
    func anchor(at location: CGPoint) -> MZRItem.Anchor? {
        guard let item = targetItem else { return nil }
        for (col, section) in item.points.enumerated() {
            for (row, point) in section.enumerated() {
                if Line(from: point, to: location).distance <= threshold {
                    return .position((col, row))
                }
            }
        }
        return .point(location)
    }
    
    func radian(_ location: CGPoint) -> CGFloat {
        return Line(from: points[0][0], to: location).radian
    }
    
    // MARK: - Drawing
    
    override func draw() {
        guard let context = CGContext.current else { return }
        
        let outterCircle = Circle(center: points[0][0], radius: threshold)
        context.saveGState()
        defer { context.restoreGState() }
        context.setStrokeColor(MZRMakeCGColor(r: 1, g: 0, b: 0, a: 1))
        outterCircle.stroke()
    }
    
    func contains(_ location: CGPoint) -> Bool {
        return Line(from: points[0][0], to: location).distance <= threshold
    }
    
}
