//
//  BezierPath+Ext.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/8.
//

extension MZRBezierPath {
    
    public func addLine(_ line: Line) {
        #if os(OSX)
        move(to: line.from)
        self.line(to: line.to)
        #else
        move(to: line.from)
        addLine(to: line.to)
        #endif
    }
    
    public func addArc(_ arc: Arc, pie: Bool = false) {
        #if os(OSX)
        if pie { move(to: arc.center) }
        
        defer {
            if pie { line(to: arc.center) }
        }
        appendArc(withCenter: arc.center, radius: arc.radius,
                  startAngle: arc.startAngle, endAngle: arc.endAngle,
                  clockwise: arc.clockwise)
        #else
        addArc(withCenter: arc.center, radius: arc.radius,
               startAngle: arc.startAngle, endAngle: arc.endAngle,
               clockwise: arc.clockwise)
        #endif
    }
    
    public func addCircle(_ circle: Circle) {
        #if os(OSX)
        appendArc(withCenter: circle.center, radius: circle.radius,
                  startAngle: 0, endAngle: .pi * 2)
        #else
        addArc(withCenter: circle.center, radius: circle.radius,
               startAngle: 0, endAngle: .pi * 2,
               clockwise: true)
        #endif
    }
    
    public func addSquare(_ square: Square) {
        #if os(OSX)
        move(to: square.points[0])
        line(to: square.points[1])
        line(to: square.points[2])
        line(to: square.points[3])
        line(to: square.points[0])
        #else
        move(to: square.points[0])
        addLine(to: square.points[1])
        addLine(to: square.points[2])
        addLine(to: square.points[3])
        addLine(to: square.points[0])
        #endif
    }
    
}
