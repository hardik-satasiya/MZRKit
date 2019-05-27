//
//  Square.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

import Foundation

public struct Square {
    
    public let points: [CGPoint]
    
    public let width: CGFloat
    
    public init(_ diagonal: Line) {
        let center = diagonal.midpoint
        let len = diagonal.distance / 2
        points = [diagonal.from, center.extended(length: len, angle: diagonal.radian + .pi / 2),
                  diagonal.to, center.extended(length: len, angle: diagonal.radian - .pi / 2)]
        width = Line(from: points[0], to: points[1]).distance
    }
    
    // MARK: - Selection
    
    public func canSelected(by rect: CGRect) -> Bool {
        let numPoints = points.count
        for i in 0..<numPoints {
            let p1 = points[i], p2 = points[(i + 1) % numPoints]
            if Line(from: p1, to: p2).canSelected(by: rect) { return true }
            if rect.contains(points[i]) { return true }
        }
        return false
    }
    
    // MARK: - Drawing
    
    public func stroke() {
        CGContext.current?.addSquare(self)
        CGContext.current?.strokePath()
    }

}
