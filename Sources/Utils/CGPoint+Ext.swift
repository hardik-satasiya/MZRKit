//
//  CGPoint+Ext.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/6.
//

extension CGPoint: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    public func rotated(center: CGPoint, angle: CGFloat) -> CGPoint {
        let transform = CGAffineTransform.identity.translatedBy(x: center.x, y: center.y).rotated(by: angle)
        return CGPoint(x: x - center.x, y: y - center.y).applying(transform)
    }
    
    public mutating func rotate(center: CGPoint, angle: CGFloat) {
        self = rotated(center: center, angle: angle)
    }
    
}

extension CGPoint {
    
    public func extended(length: CGFloat, angle: CGFloat) -> CGPoint {
        return CGPoint(x: x + length * cos(angle), y: y + length * sin(angle))
    }
    
    public mutating func extend(length: CGFloat, angle: CGFloat) {
        self = self.extended(length: length, angle: angle)
    }
    
}

extension Array where Element == CGPoint {
    
    public func rotated(center: CGPoint, angle: CGFloat) -> [CGPoint] {
        let transform = CGAffineTransform.identity.translatedBy(x: center.x, y: center.y).rotated(by: angle)
        let newPoints = map { point in
            CGPoint(x: point.x - center.x, y: point.y - center.y).applying(transform)
        }
        
        return newPoints
    }
    
    public mutating func rotate(center: CGPoint, angle: CGFloat) {
        self = rotated(center: center, angle: angle)
    }
    
}
