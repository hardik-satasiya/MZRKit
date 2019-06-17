//
//  Utils.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

// MARK: - Color

#if os(OSX)
public typealias MZRColor = NSColor
public typealias MZRBezierPath = NSBezierPath
#else
public typealias MZRColor = UIColor
public typealias MZRBezierPath = UIBezierPath
#endif

// MARK: - Angle

let Radian90 = CGFloat.pi / 2

func MZRCalcAngle(_ v: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat? {
    let len1 = Line(from: v, to: a).distance
    let len2 = Line(from: v, to: b).distance
    let len3 = Line(from: a, to: b).distance
    let a = (len1 * len1 + len2 * len2 - len3 * len3)
    let b = (len1 * len2 * 2.0)
    return b == 0 ? nil : acos(a / b)
}

public func MZRRadianFromDegree(_ d: CGFloat) -> CGFloat {
    return .pi / 180 * d
}

public func MZRDegreeFromRadian(_ r: CGFloat) -> CGFloat {
    return 180 / .pi * r
}

// MARK: - Aspect Fit

public func MZRMakeRect(aspectRatio: CGSize, in rect: CGRect) -> CGRect {
    let m1 = rect.width / rect.height
    let m2 = aspectRatio.width / aspectRatio.height
    var w = CGFloat(0), h = CGFloat(0)
    
    if m1 > m2 {
        h = rect.height
        w = h * aspectRatio.width / aspectRatio.height
    }
    else if m1 < m2 {
        w = rect.width
        h = w * aspectRatio.height / aspectRatio.width
    }
    else {
        return rect
    }
    
    return CGRect(x: rect.midX - w / 2, y: rect.midY - h / 2, width: w, height: h)
}

// MARK: - Square

func MZRMakeSquare(_ line: Line) -> (CGPoint, CGPoint, CGPoint, CGPoint) {
    let center = line.midpoint
    let len    = line.distance / 2
    let p1     = line.from
    let p2     = center.extended(length: len, angle: line.radian + .pi / 2)
    let p3     = line.to
    let p4     = center.extended(length: len, angle: line.radian - .pi / 2)
    return (p1, p2, p3, p4)
}

// MARK: - Circle

fileprivate func calcA(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat {
    return (p1.x * (p2.y - p3.y) - p1.y * (p2.x - p3.x) + p2.x * p3.y - p3.x * p2.y)
}

fileprivate func calcB(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat{
    let a = (p1.x * p1.x + p1.y * p1.y) * (p3.y - p2.y)
    let b = (p2.x * p2.x + p2.y * p2.y) * (p1.y - p3.y)
    let c = (p3.x * p3.x + p3.y * p3.y) * (p2.y - p1.y)
    return a + b + c
}

fileprivate func calcC(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat{
    let a = (p1.x * p1.x + p1.y * p1.y) * (p2.x - p3.x)
    let b = (p2.x * p2.x + p2.y * p2.y) * (p3.x - p1.x)
    let c = (p3.x * p3.x + p3.y * p3.y) * (p1.x - p2.x)
    return a + b + c
}

fileprivate func calcD(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat {
    let a = (p1.x * p1.x + p1.y * p1.y) * (p3.x * p2.y - p2.x * p3.y)
    let b = (p2.x * p2.x + p2.y * p2.y) * (p1.x * p3.y - p3.x * p1.y)
    let c = (p3.x * p3.x + p3.y * p3.y) * (p2.x * p1.y - p1.x * p2.y)
    return a + b + c
}

public func MZRMakeCircle(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) -> (center: CGPoint, radius: CGFloat)? {
    let a = calcA(point1, point2, point3)
    let b = calcB(point1, point2, point3)
    let c = calcC(point1, point2, point3)
    let d = calcD(point1, point2, point3)
    let center = CGPoint(x: -b / (2 * a), y: -c / (2 * a))
    let radius = sqrt((b * b + c * c - (4 * a * d)) / (4 * a * a))
    
    guard (!center.x.isNaN && !center.x.isInfinite) &&
            (!center.y.isNaN && !center.y.isInfinite) &&
            (!radius.isNaN && !radius.isInfinite) else
    {
        return nil
    }

    return (center, radius)
}
