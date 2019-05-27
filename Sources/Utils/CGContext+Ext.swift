//
//  CGContext+Ext.swift
//  MZRKit iOS
//
//  Created by scchnxx on 2019/4/8.
//

import CoreGraphics

extension CGContext {
    
    public static var current: CGContext? {
        #if os(OSX)
        return NSGraphicsContext.current?.cgContext
        #else
        return UIGraphicsGetCurrentContext()
        #endif
    }
    
    func addLine(_ line: Line) {
        addLines(between: [line.from, line.to])
    }
    
    func addArc(_ arc: Arc, pie: Bool = false) {
        if pie { move(to: arc.center) }
        
        defer {
            if pie { addLine(to: arc.center) }
        }
        addArc(center: arc.center, radius: arc.radius,
               startAngle: arc.startAngle, endAngle: arc.endAngle,
               clockwise: arc.clockwise)
    }
    
    func addCircle(_ circle: Circle) {
        addArc(center: circle.center, radius: circle.radius,
               startAngle: 0, endAngle: .pi * 2,
               clockwise: true)
    }
    
    func addSquare(_ square: Square) {
        let points = square.points
        move(to: points[0])
        addLine(to: points[1])
        addLine(to: points[2])
        addLine(to: points[3])
        addLine(to: points[0])
    }
    
}
