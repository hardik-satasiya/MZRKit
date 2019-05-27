//
//  MZRCircle2.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRCircle2: MZRItem, CircleMeasurable {
    
    private var circle: Circle?
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            guard isCompleted else { return }
            circle = Circle(points[0][0], points[0][1], points[0][2])
        }
    }
    
    // MARK: - CircleMeasurable
    
    public var radius: CGFloat { return circle?.radius ?? 0 }
    
    public var center: CGPoint { return circle?.center ?? .zero }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.std(1, 3))
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current else { return }
        guard isCompleted else { return }
        guard let circle = Circle(points[0][0], points[0][1], points[0][2]) else { return }
        context.saveGState()
        defer { context.restoreGState() }
        context.addCircle(circle)
        context.setStrokeColor(color)
        context.strokePath()
    }
    
    public override func path() -> CGPath? {
        guard let circle = circle, isCompleted else { return nil }
        let path = CGMutablePath()
        path.addCircle(circle)
        return path
    }
    
    // MARK: - Selection
    
    public override func canSelected(by rect: CGRect) -> Bool {
        return circle?.canSelected(by: rect) ?? false
    }
    
}
