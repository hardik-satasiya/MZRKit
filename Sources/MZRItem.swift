//
//  MZRTool.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/5.
//



extension MZRItem {
    
    public enum Size: Equatable, Hashable {
        case std(Int, Int)
        case inf(continuous: Bool, cuttable: Bool)
        
        func max() -> Int? {
            switch self {
            case .std(let cols, let rows):
                return cols * rows
            default:
                return nil
            }
        }
    }
    
    public enum Anchor: Equatable {
        
        public static func == (lhs: MZRItem.Anchor, rhs: MZRItem.Anchor) -> Bool {
            if case .position(let pos1) = lhs, case .position(let pos2) = rhs { return pos1 == pos2 }
            if case .point(let pos1) = lhs, case .point(let pos2) = rhs       { return pos1 == pos2 }
            return false
        }
        
        case position(Position)
        case point(CGPoint)
    }
    
}

extension MZRItem: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    public static func == (lhs: MZRItem, rhs: MZRItem) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}

public class MZRItem {
    
    private let uuid = UUID().uuidString
    
    public typealias Position = (Int, Int)
    
    // MARK: - Private Properties
    
    // MARK: - Public Properties
    
    public let size: Size
    
    public internal(set) var points = [[CGPoint]]()
    
    // MARK: - Color Settings
    
    public internal(set) var color = MZRColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    public internal(set) var pointBorderColor = MZRColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    public internal(set) var pointColor = MZRColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    public internal(set) var markedPointColor = MZRColor(red: 0, green: 0.5, blue: 1, alpha: 1)
    
    // MARK: - Rotation Settings
    
    public internal(set) var rotationAnchor = Anchor.position((0, 0))
    
    public internal(set) var rotation = CGFloat(0) {
        didSet {
            guard let center = anchorPoint() else {
                rotation = 0
                return
            }
            let dr = rotation - oldValue
            for (i, section) in points.enumerated() {
                points[i] = section.rotated(center: center, angle: dr)
            }
        }
    }
    
    public internal(set) var pointRadius = CGFloat(5)
    
    // MARK: - Getters
    
    public var isCompleted: Bool {
        guard case .std = size else { return true }
        return points.flatMap({ $0 }).count == size.max()
    }
    
    func anchorPoint() -> CGPoint? {
        guard isCompleted else { return nil }
        switch rotationAnchor {
        case .point(let point): return point
        case .position(let pos): return points[pos.0][pos.1]
        }
    }
    
    // MARK: - Life Cycle
    
    internal init(_ size: Size) {
        self.size = size
    }
    
    required public init() {
        self.size = Size.inf(continuous: false, cuttable: false)
    }
    
    // MARK: - Edit
    
    public func addPoint(_ point: CGPoint) {
        switch size {
        case .std(_, let rows):
            guard !isCompleted else { return }
            guard points.isEmpty || points[points.count - 1].count >= rows else { break }
            points.append([])
        case .inf:
            guard points.last == nil else { break }
            points.append([])
        }
        
        points[points.count - 1].append(point)
    }
    
    public func modifyPoint(_ point: CGPoint, at position: Position) {
        points[position.0][position.1] = point
    }
    
    /// `offset(x:y:)` edit points directly without calling `modifyPoint(_:at:)`.
    public func offset(x: CGFloat, y: CGFloat) {
        var newPoints = points
        
        for (col, section) in newPoints.enumerated() {
            for (row, point) in section.enumerated() {
                newPoints[col][row] = CGPoint(x: point.x + x, y: point.y + y)
            }
        }
        
        points = newPoints
    }
    
    /// `offset(x:y:at:)` calls `modifyPoint()` to edit point at `position`.
    public func offset(x: CGFloat, y: CGFloat, at position: Position) {
        var newPoint = points[position.0][position.1]
        newPoint = CGPoint(x: newPoint.x + x, y: newPoint.y + y)
        modifyPoint(newPoint, at: position)
    }
    
    // MARK: - Cut
    
    /// Move to the next column. `inf` size only.
    public func cut() {
        guard case .inf(continuous: _, cuttable: let cuttable) = size, cuttable else { return }
        guard let last = points.last, !last.isEmpty else { return }
        points.append([])
    }
    
    // MARK: - Drawing
    
    private func pointBoxPath(_ point: CGPoint) -> CGPath {
        let path = CGMutablePath()
        var corners = [CGPoint]()
        for i in 0...3 {
            let r = .pi / 4 + (.pi / 2 * CGFloat(i))
            let corner = point.extended(length: pointRadius, angle: r + rotation)
            corners.append(corner)
        }
        path.addLines(between: corners)
        path.closeSubpath()
        return path
    }
    
    public func drawPoints(marked: [Position]? = nil) {
        guard let context = CGContext.current else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        for (col, section) in points.enumerated() {
            for (row, point) in section.enumerated()  {context.addPath(pointBoxPath(point))
                let bgColor = (marked?.contains { $0 == (col, row) } == true) ? markedPointColor : pointColor
                context.setFillColor(bgColor.cgColor)
                context.fillPath()
                context.addPath(pointBoxPath(point))
                context.setStrokeColor(pointBorderColor.cgColor)
                context.strokePath()
            }
        }
    }
    
    public func drawArch() {
        guard let context = CGContext.current else { return }
        for section in points {
            for (idx, point) in section.enumerated() {
                (idx == 0) ? context.move(to: point) : context.addLine(to: point)
            }
        }
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineDash(phase: 0, lengths: [2, 2])
        context.strokePath()
        context.restoreGState()
    }
    
    public func draw() {
        guard let context = CGContext.current else { return }
        guard isCompleted else { return }
        
        for section in points {
            for (idx, point) in section.enumerated() {
                if idx == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        }
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.strokePath()
        context.restoreGState()
    }
    
    // MARK: - Path
    
    public func path() -> CGPath? {
        guard isCompleted else { return nil }
        
        let path = CGMutablePath()
        
        for section in points {
            path.addLines(between: section)
        }
        
        return path
    }
    
    // MARK: - Selection
    
    public func canSelected(by rect: CGRect) -> Bool {
        for section in points {
            for (i, point) in section.enumerated() {
                let p1 = point, p2 = section[(i + 1) % section.count]
                if Line(from: p1, to: p2).canSelected(by: rect) { return true }
            }
        }
        return false
    }
    
}
