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
    
}

extension CGPoint {
    
    func extended(length: CGFloat, angle: CGFloat) -> CGPoint {
        return CGPoint(x: x + length * cos(angle), y: y + length * sin(angle))
    }
    
    mutating func extend(length: CGFloat, angle: CGFloat) {
        self = self.extended(length: length, angle: angle)
    }
    
}

extension Array where Element == CGPoint {
    
    func rotated(center: CGPoint, angle: CGFloat) -> [CGPoint] {
        let transform = CGAffineTransform.identity.translatedBy(x: center.x, y: center.y).rotated(by: angle)
        let newPoints = map { point in
            CGPoint(x: point.x - center.x, y: point.y - center.y).applying(transform)
        }
        
        return newPoints
    }
    
    mutating func rotate(center: CGPoint, angle: CGFloat) {
        self = self.rotated(center: center, angle: angle)
    }
    
}
