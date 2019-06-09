//
//  BezierPath+Ext.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/8.
//

#if os(OSX)
extension NSBezierPath {
    
    public func appendLine(_ line: Line) {
        move(to: line.from)
        self.line(to: line.to)
    }
    
    public func appendArc(_ arc: Arc, pie: Bool = false) {
        if pie { move(to: arc.center) }
        
        defer {
            if pie { line(to: arc.center) }
        }
        appendArc(withCenter: arc.center, radius: arc.radius,
                  startAngle: arc.startAngle, endAngle: arc.endAngle,
                  clockwise: arc.clockwise)
    }
    
    public func appendCircle(_ circle: Circle) {
        appendArc(withCenter: circle.center, radius: circle.radius,
                  startAngle: 0, endAngle: .pi * 2)
    }
    
    public func appendSquare(_ square: Square) {
        move(to: square.points[0])
        line(to: square.points[1])
        line(to: square.points[2])
        line(to: square.points[3])
        line(to: square.points[0])
    }
    
}
#else
extension UIBezierPath {
    
    public func addLine(_ line: Line) {
        move(to: line.from)
        addLine(to: line.to)
    }
    
    public func addArc(_ arc: Arc) {
        addArc(withCenter: arc.center, radius: arc.radius,
               startAngle: arc.startAngle, endAngle: arc.endAngle,
               clockwise: arc.clockwise)
    }
    
    public func addCircle(_ circle: Circle) {
        addArc(withCenter: circle.center, radius: circle.radius,
               startAngle: 0, endAngle: .pi * 2,
               clockwise: true)
    }
    
    public func addSquare(_ square: Square) {
        move(to: square.points[0])
        addLine(to: square.points[1])
        addLine(to: square.points[2])
        addLine(to: square.points[3])
        addLine(to: square.points[0])
    }
    
}
#endif
