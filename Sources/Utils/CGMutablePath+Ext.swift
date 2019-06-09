//
//  CGMutablePath+Ext.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/8.
//

import CoreGraphics

extension CGMutablePath {
    
    public func addLine(_ line: Line) {
        addLines(between: [line.from, line.to])
    }
    
    public func addArc(_ arc: Arc, pie: Bool = false) {
        if pie { move(to: arc.center) }
        
        defer {
            if pie { addLine(to: arc.center) }
        }
        addArc(center: arc.center, radius: arc.radius,
               startAngle: arc.startAngle, endAngle: arc.endAngle,
               clockwise: arc.clockwise)
    }
    
    public func addCircle(_ circle: Circle) {
        addArc(center: circle.center, radius: circle.radius,
               startAngle: 0, endAngle: .pi * 2,
               clockwise: true)
    }
    
    public func addSquare(_ square: Square) {
        addLines(between: square.points)
    }
    
}
