//
//  Arc.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/6.
//

public struct Arc {
    
    public var center: CGPoint
    
    public var radius: CGFloat
    
    public var startAngle: CGFloat
    
    public var endAngle: CGFloat
    
    public var clockwise: Bool
    
    public init(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        self.center     = center
        self.radius     = radius
        self.startAngle = startAngle
        self.endAngle   = endAngle
        self.clockwise  = clockwise
    }
    
    /// Pie
    public init(center: CGPoint, radius: CGFloat, point1: CGPoint, point2: CGPoint) {
        let rab = Line(from: center, to: point1).radian
        let rac = Line(from: center, to: point2).radian
        
        self.center = center
        self.radius = radius
        
        startAngle = (rab >= 0 ? rab : 2 * .pi + rab)
        endAngle   = (rac >= 0 ? rac : 2 * .pi + rac)
        
        if startAngle > endAngle {
            swap(&startAngle, &endAngle)
        }
        
        clockwise = (endAngle - startAngle) > .pi
    }
    
    // MARK: - Drawing
    
    public func stroke(pie: Bool = false) {
        guard let context = CGContext.current else { return }
        context.addArc(self, pie: pie)
        context.strokePath()
    }
    
}
