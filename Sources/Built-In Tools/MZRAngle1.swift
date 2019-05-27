//
//  MZRAngle1.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRAngle1: MZRItem, AngleMeasurable1 {
    
    private var arc: Arc?
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            guard isCompleted else { return }
            angle = MZRCalcAngle(points[0][0], points[0][1], points[0][2]) ?? 0
            arc = Arc(center: points[0][1], radius: 20, point1: points[0][0], point2: points[0][2])
        }
    }
    
    // MARK: - AngleMeasurable1
    
    public private(set) var angle: CGFloat = 0
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.std(1, 3))
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        super.draw()
        
        guard let context = CGContext.current, let arc = arc, angle != Radian90, isCompleted else { return }
        context.saveGState()
        defer { context.restoreGState() }
        context.setLineDash(phase: 0, lengths: [3, 3])
        arc.stroke(pie: true)
    }
    
    // MARK: - Path
    
    public override func path() -> CGPath? {
        guard let arc = arc, let points = points.first, isCompleted else { return nil }
        let path = CGMutablePath()
        path.addLines(between: points)
        path.addArc(arc, pie: true)
        return path
    }
    
}
