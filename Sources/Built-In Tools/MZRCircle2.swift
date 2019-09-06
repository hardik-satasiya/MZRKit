//
//  MZRCircle2.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRCircle2: MZRItem, CircleMeasurable, LineTrackable {
    
    private var circle: Circle?
    weak var tracker: MZRLine?
    var trackerPosition = Position(0, 0)
    var trackedPoint: CGPoint { center }
    
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
    
    public override func modifyPoint(_ point: CGPoint, at position: MZRItem.Position) {
        let shouldUpdateTracker = tracker?.points[trackerPosition.0][trackerPosition.1] == trackedPoint
        
        super.modifyPoint(point, at: position)
        
        if shouldUpdateTracker {
            updateTracker()
        } else {
            removeTracker()
        }
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current else { return }
        guard isCompleted else { return }
        guard let circle = Circle(points[0][0], points[0][1], points[0][2]) else { return }
        context.saveGState()
        defer { context.restoreGState() }
        color.setStroke()
        circle.stroke()
        let centerCircle = Circle(center: circle.center, radius: 2)
        color.setFill()
        centerCircle.fill()
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
