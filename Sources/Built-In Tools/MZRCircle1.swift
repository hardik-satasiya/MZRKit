//
//  MZRCircle1.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRCircle1: MZRItem, CircleMeasurable {
    
    private var circle: Circle?
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            guard isCompleted else { return }
            let line = Line(from: points[0][0], to: points[0][1])
            circle = Circle(center: line.midpoint, radius: line.distance / 2)
        }
    }
    
    // MARK: - CircleMeasurable
    
    public var radius: CGFloat { return circle?.radius ?? 0 }
    
    public var center: CGPoint { return circle?.center ?? .zero }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.std(1, 2))
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current else { return }
        guard let circle = circle else { return }
        context.saveGState()
        defer { context.restoreGState() }
        context.addCircle(circle)
        context.setStrokeColor(color)
        context.strokePath()
    }
    
    // MARK: - Path
    
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
