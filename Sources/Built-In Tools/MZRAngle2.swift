//
//  MZRAngle2.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRAngle2: MZRItem, AngleMeasurable1 {
    
    private var targetPoint: CGPoint?
    
    private var arc: Arc?
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            guard isCompleted else { return }
            
            let dx = points[0][1].x - points[0][2].x
            let dy = points[0][1].y - points[0][2].y
            let point = CGPoint(x: points[0][1].x + dx, y: points[0][1].y + dy)
            targetPoint = point
            arc = Arc(center: points[0][1], radius: 20, point1: points[0][0], point2: point)
        }
    }
    
    // MARK: - AngleMeasurable1
    
    public var angle: CGFloat {
        guard let targetPoint = targetPoint else { return 0}
        return MZRCalcAngle(points[0][1], points[0][0], targetPoint) ?? 0
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.std(1, 3))
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        super.draw()
        
        guard let context = CGContext.current, let targetPoint = targetPoint, let arc = arc else { return }
        context.saveGState()
        defer { context.restoreGState() }
        color.setStroke()
        context.setLineDash(phase: 0, lengths: [3, 3])
        arc.stroke()
        context.move(to: points[0][1])
        context.addLine(to: targetPoint)
        context.strokePath()
    }
    
    // MARK: - Path
    
    public override func path() -> CGPath? {
        guard let arc = arc, let targetPoint = targetPoint, isCompleted else { return nil }
        let path = CGMutablePath()
        path.addPath(super.path()!)
        path.addArc(arc, pie: true)
        path.move(to: points[0][1])
        path.addLine(to: targetPoint)
        return path
    }
    
    // MARK: - Selection
    
    public override func canSelected(by rect: CGRect) -> Bool {
        if super.canSelected(by: rect) { return true }
        guard let targetPoint = targetPoint else { return false }
        return Line(from: points[0][1], to: targetPoint).canSelected(by: rect)
    }
    
}
