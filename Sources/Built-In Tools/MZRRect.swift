//
//  MZRRect.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

/*
 
 0-------1
 |       |
 |       |
 3-------2

 */

extension MZRRect {
    
    public struct Flip: OptionSet {
        
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let vertical = Flip(rawValue: 1 << 0)
        
        public static let horizontal = Flip(rawValue: 1 << 1)
        
    }
    
}

public class MZRRect: MZRItem, RectangleMeasurable {
    
    public var flip = Flip(rawValue: 0)
    
    // MARK: - RectangleMeasurable
    
    public var width: CGFloat {
        guard isCompleted else { return 0 }
        return Line(from: points[0][0], to: points[0][1]).distance
    }
    
    public var height: CGFloat {
        guard isCompleted else { return 0 }
        return Line(from: points[0][0], to: points[0][3]).distance
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.std(1, 4))
    }
    
    // MARK: - Edit
    
    private func updateFlip(unrotatedPoints: [CGPoint]) {
        guard unrotatedPoints.count == 4 else { return }
        
        if points[0][1].x - points[0][0].x < 0 {
            flip.update(with: .horizontal)
        } else {
            flip.remove(.horizontal)
        }
        
        if points[0][0].y - points[0][3].y < 0 {
            flip.update(with: .vertical)
        } else {
            flip.remove(.vertical)
        }
    }
    
    public override func addPoint(_ point: CGPoint) {
        guard !isCompleted else { return }
        
        if points.first == nil {
            super.addPoint(point)
        } else {
            let maxX = max(points[0][0].x, point.x)
            let minX = min(points[0][0].x, point.x)
            let maxY = max(points[0][0].y, point.y)
            let minY = min(points[0][0].y, point.y)
            super.addPoint(CGPoint(x: maxX, y: minY))
            super.addPoint(CGPoint(x: maxX, y: maxY))
            super.addPoint(CGPoint(x: minX, y: maxY))
            updateFlip(unrotatedPoints: points[0])
        }
    }
    
    public override func modifyPoint(_ point: CGPoint, at position: MZRItem.Position) {
        guard let anchorPoint = anchorPoint() else { return }
        
        let index = position.1
        var newPoints = points[0].enumerated().map({ $0 != index ? $1 : point }).rotated(center: anchorPoint, angle: -rotation)
        
        switch index {
        case 0:  newPoints[1].y = newPoints[index].y; newPoints[3].x = newPoints[index].x
        case 1:  newPoints[0].y = newPoints[index].y; newPoints[2].x = newPoints[index].x
        case 2:  newPoints[1].x = newPoints[index].x; newPoints[3].y = newPoints[index].y
        default: newPoints[0].x = newPoints[index].x; newPoints[2].y = newPoints[index].y
        }
        
        updateFlip(unrotatedPoints: newPoints)
        points[0] = newPoints.rotated(center: anchorPoint, angle: rotation)
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current, isCompleted else { return }
        
        context.saveGState()
        defer {
            context.restoreGState()
        }
        context.addLines(between: points[0])
        context.addLine(to: points[0][0])
        context.strokePath()
    }
    
    // MARK: - Path
    
    public override func path() -> CGPath? {
        guard let points = points.first, isCompleted else { return nil }
        let path = CGMutablePath()
        path.addLines(between: points)
        path.addLine(to: points[0])
        return path
    }
    
}
