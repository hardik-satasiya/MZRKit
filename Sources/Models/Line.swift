//
//  Line.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/6.
//

extension Line {
    
    public enum IntersectionType {
        case intersection(CGPoint)
        case coline
        case parallel
    }
    
}

public struct Line {
    
    public var from: CGPoint
    
    public var to: CGPoint
    
    public init(from: CGPoint, to: CGPoint) {
        self.from = from
        self.to = to
    }
    
    public init(center: CGPoint, radius: CGFloat, angle: CGFloat) {
        from = center
        to = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
    }
    
    public var distance: CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
    
    public var midpoint: CGPoint {
        return CGPoint(x: (from.x + to.x) / 2.0, y: (from.y + to.y) / 2.0)
    }
    
    public var slope: CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        return dy / dx
    }
    
    public var vector: CGVector {
        let dx = to.x - from.x
        let dy = to.y - from.y
        return CGVector(dx: dx, dy: dy)
    }
    
    public func distance(_ point: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let A = abs(dy * point.x - dx * point.y + to.x * from.y - to.y * from.x)
        let B = sqrt(pow(to.y - from.y, 2) + pow(to.x - from.x, 2))
        return A / B
    }
    
    public func contains(_ point: CGPoint) -> Bool {
        let A = (from.x - point.x) * (from.x - point.x) + (from.y - point.y) * (from.y - point.y);
        let B = (to.x - point.x) * (to.x - point.x) + (to.y - point.y) * (to.y - point.y);
        let C = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
        return (A + B + 2 * sqrt(A * B) - C < 1)
    }
    
    public func intersection(_ line: Line) -> IntersectionType {
        let EPS: CGFloat = 1e-5
        func EQ(_ x: CGFloat, _ y: CGFloat) -> Bool { return abs(x - y) < EPS }
        let A1 = to.y - from.y
        let B1 = from.x - to.x
        let C1 = to.x  * from.y - from.x * to.y
        let A2 = line.to.y - line.from.y
        let B2 = line.from.x - line.to.x
        let C2 = line.to.x * line.from.y - line.from.x * line.to.y
        if EQ(A1 * B2, B1 * A2) {
            return EQ( (A1 + B1) * C2, (A2 + B2) * C1 ) ? .coline : .parallel
        } else {
            let crossPoint = CGPoint(x: (B2 * C1 - B1 * C2) / (A2 * B1 - A1 * B2),
                                     y: (A1 * C2 - A2 * C1) / (A2 * B1 - A1 * B2))
            return .intersection(crossPoint)
        }
    }
    
    public var radian: CGFloat {
        return atan2(to.y - from.y, to.x - from.x)
    }
    
    public func radian(point: CGPoint) -> CGFloat? {
        return MZRCalcAngle(from, to, point)
    }
    
    public func paralles(_ length: CGFloat) -> (Line, Line) {
        let radian1 = radian
        let line1 = Line(from: CGPoint(x: from.x + length * cos(radian1 + CGFloat.pi / 2.0),
                                              y: from.y + length * sin(radian1 + CGFloat.pi / 2.0)),
                                to: CGPoint(x: from.x + length * cos(radian1 - CGFloat.pi / 2.0),
                                            y: from.y + length * sin(radian1 - CGFloat.pi / 2.0)))
        
        let radian2 = Line(from: to, to: from).radian
        let line2 = Line(from: CGPoint(x: to.x + length * cos(radian2 + CGFloat.pi / 2.0),
                                              y: to.y + length * sin(radian2 + CGFloat.pi / 2.0)),
                                to: CGPoint(x: to.x + length * cos(radian2 - CGFloat.pi / 2.0),
                                            y: to.y + length * sin(radian2 - CGFloat.pi / 2.0)))
        
        return (line1, line2)
    }
    
    // MARK: - Selection
    
    public func canSelected(by rect: CGRect) -> Bool {
        if rect.contains(from) || rect.contains(to) {
            return true
        }
        return lineRect(from.x, from.y, to.x, to.y, rect.minX, rect.minY, abs(rect.width), abs(rect.height))
    }
    
    private func lineRect(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat,
                          _ rx: CGFloat, _ ry: CGFloat, _ rw: CGFloat, _ rh: CGFloat) -> Bool
    {
        let left = lineLine(x1, y1, x2, y2, rx,ry,rx, ry + rh);
        let right = lineLine(x1, y1, x2, y2, rx+rw,ry, rx + rw,ry + rh);
        let top = lineLine(x1, y1, x2, y2, rx, ry, rx + rw, ry);
        let bottom = lineLine(x1, y1, x2, y2, rx, ry + rh, rx + rw,ry + rh);
        if (left || right || top || bottom) { return true }
        return false;
    }
    
    private func lineLine(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat,
                          _ x3: CGFloat, _ y3: CGFloat, _ x4: CGFloat, _ y4: CGFloat) -> Bool
    {
        let uA = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))
        let uB = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))
        if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) { return true }
        return false;
    }
    
    // MARK: - Drawing
    
    public func stroke() {
        CGContext.current?.addLine(self)
        CGContext.current?.strokePath()
    }
    
}
