//
//  MZRSquare.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRSquare: MZRItem, RectangleMeasurable {
    
    private var square: Square?
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            guard isCompleted else { return }
            square = Square(Line(from: points[0][0], to: points[0][1]))
        }
    }
    
    // MARK: - RectangleMeasurable
    
    public var width: CGFloat { return square?.width ?? 0 }
    
    public var height: CGFloat { return square?.width ?? 0 }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(Size.std(1, 2))
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current else { return }
        guard let square = square else { return }
        context.saveGState()
        defer { context.restoreGState() }
        context.addSquare(square)
        context.setStrokeColor(color)
        context.strokePath()
    }
    
    // MARK: - Path
    
    public override func path() -> CGPath? {
        guard let points = square?.points, isCompleted else { return nil }
        let path = CGMutablePath()
        path.addLines(between: points)
        path.addLine(to: points[0])
        return path
    }
    
    // MARK: - Selection
    
    public override func canSelected(by rect: CGRect) -> Bool {
        return square?.canSelected(by: rect) ?? false
    }
    
}
