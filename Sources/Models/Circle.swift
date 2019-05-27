//
//  Circle.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/6.
//

public struct Circle {
    
    public var center: CGPoint
    
    public var radius: CGFloat
    
    public init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }
    
    public init?(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) {
        guard let circle = MZRMakeCircle(point1, point2, point3) else { return nil }
        center = circle.center
        radius = circle.radius
    }
    
    // MARK: - Selection
    
    public func canSelected(by rect: CGRect) -> Bool {
        var dx = max(rect.maxX - center.x, center.x - rect.minX)
        var dy = max(rect.maxY - center.y, center.y - rect.minY)
        guard !(dx * dx + dy * dy < radius * radius) else { return false }
        dx = center.x - max(rect.minX, min(center.x, rect.minX + rect.width))
        dy = center.y - max(rect.minY, min(center.y, rect.minY + rect.height))
        return dx * dx + dy * dy < radius * radius
    }
    
    // MARK: - Drawing
    
    public func stroke() {
        CGContext.current?.addCircle(self)
        CGContext.current?.strokePath()
    }
    
    public func fill() {
        CGContext.current?.addCircle(self)
        CGContext.current?.fillPath()
    }
    
}


