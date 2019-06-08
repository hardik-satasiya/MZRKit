//
//  MZRRect.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

/*
 
 0---1---2
 |       |
 6       3
 |       |
 5---4---7

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
        return Line(from: points[0][0], to: points[0][2]).distance
    }
    
    public var height: CGFloat {
        guard isCompleted else { return 0 }
        return Line(from: points[0][0], to: points[0][5]).distance
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.std(1, 8))
    }
    
    // MARK: - Edit
    
    private func updateFlip(unrotatedPoints: [CGPoint]) {
        guard unrotatedPoints.count == 8 else { return }
        
        if points[0][2].x - points[0][0].x < 0 {
            flip.update(with: .horizontal)
        } else {
            flip.remove(.horizontal)
        }
        
        if points[0][0].y - points[0][5].y < 0 {
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
            let rect = CGRect(x: points[0][0].x, y: points[0][0].y,
                              width: point.x - points[0][0].x, height: point.y - points[0][0].y)
            
            super.addPoint(CGPoint(x: rect.midX, y: rect.maxY))
            super.addPoint(CGPoint(x: rect.maxX, y: rect.maxY))
            super.addPoint(CGPoint(x: rect.maxX, y: rect.midY))
            super.addPoint(CGPoint(x: rect.midX, y: rect.minY))
            super.addPoint(CGPoint(x: rect.minX, y: rect.minY))
            super.addPoint(CGPoint(x: rect.minX, y: rect.midY))
            super.addPoint(CGPoint(x: rect.maxX, y: rect.minY))
            updateFlip(unrotatedPoints: points[0])
        }
    }
    
    public override func modifyPoint(_ point: CGPoint, at position: MZRItem.Position) {
        guard let anchorPoint = anchorPoint() else { return }
        
        let index = position.1
        var newPoints = points[0].enumerated().map({ $0 != index ? $1 : point }).rotated(center: anchorPoint, angle: -rotation)
        
        switch index {
        case 0:
            newPoints[2].y = newPoints[index].y
            newPoints[5].x = newPoints[index].x
            
        case 2:
            newPoints[0].y = newPoints[index].y
            newPoints[7].x = newPoints[index].x
            
        case 7:
            newPoints[2].x = newPoints[index].x
            newPoints[5].y = newPoints[index].y
            
        case 5:
            newPoints[0].x = newPoints[index].x
            newPoints[7].y = newPoints[index].y
            
        case 1:
            let point = point.rotated(center: anchorPoint, angle: -rotation)
            newPoints[0].y = point.y
            newPoints[2].y = point.y
            
        case 3:
            let point = point.rotated(center: anchorPoint, angle: -rotation)
            newPoints[2].x = point.x
            newPoints[7].x = point.x
            
        case 4:
            let point = point.rotated(center: anchorPoint, angle: -rotation)
            newPoints[5].y = point.y
            newPoints[7].y = point.y
            
        case 6:
            let point = point.rotated(center: anchorPoint, angle: -rotation)
            newPoints[0].x = point.x
            newPoints[5].x = point.x
            
        default: return
        }
        
        newPoints[1] = CGPoint(x: (newPoints[0].x + newPoints[2].x) / 2, y: newPoints[0].y)
        newPoints[4] = CGPoint(x: (newPoints[5].x + newPoints[7].x) / 2, y: newPoints[5].y)
        newPoints[3] = CGPoint(x: newPoints[2].x, y: (newPoints[2].y + newPoints[7].y) / 2)
        newPoints[6] = CGPoint(x: newPoints[0].x, y: (newPoints[0].y + newPoints[5].y) / 2)
        
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
        
        let cornerIndexes = [0, 2, 7, 5]
        context.addLines(between: cornerIndexes.map({ points[0][$0] }))
        context.closePath()
        context.setStrokeColor(color)
        context.strokePath()
    }
    
    // MARK: - Path
    
    public override func path() -> CGPath? {
        guard isCompleted else { return nil }
        let path = CGMutablePath()
        let cornerIndexes = [0, 2, 7, 5]
        path.addLines(between: cornerIndexes.map({ points[0][$0] }))
        path.closeSubpath()
        return path
    }
    
    public override func canSelected(by rect: CGRect) -> Bool {
        let cornerIndexes = [0, 2, 7, 5]
        let corners = cornerIndexes.map { points[0][$0] }
        for (i, point) in corners.enumerated() {
            let p1 = point, p2 = corners[(i + 1) % corners.count]
            if Line(from: p1, to: p2).canSelected(by: rect) { return true }
        }
        return false
    }
    
}
