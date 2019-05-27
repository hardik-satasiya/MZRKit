//
//  MZRAngle3.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRAngle3: MZRItem, AngleMeasurable2 {
    
    private var crossPoint: CGPoint?
    
    private var arcs = [(vertext: CGPoint, point1: CGPoint, point2: CGPoint)]()
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            guard isCompleted else { return }
            
            let line1 = Line(from: points[0][0], to: points[0][1])
            let line2 = Line(from: points[1][0], to: points[1][1])
            
            arcs = []
            
            if case .intersection(let point) = line1.intersection(line2) {
                crossPoint = point
                
                for point1 in points[0] {
                    for point2 in points[1] {
                        guard let radian = MZRCalcAngle(point, point1, point2),
                            MZRDegreeFromRadian(radian) - 90 < -0.1 else { continue }
                        arcs.append((point, point1, point2))
                    }
                }
            } else {
                crossPoint = nil
            }
        }
    }
    
    // MARK: - AngleMeasurable2
    
    public var acuteAngle: CGFloat = 0
    
    public var obtuseAngle: CGFloat = 0
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.std(2, 2))
    }
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current, isCompleted else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        context.setStrokeColor(color)
        
        if !arcs.isEmpty {
            for arc in arcs {
                let point1 = arc.vertext.extended(length: 20, angle: Line(from: arc.vertext, to: arc.point1).radian)
                let point2 = arc.vertext.extended(length: 20, angle: Line(from: arc.vertext, to: arc.point2).radian)
                let line1 = Line(from: arc.point1, to: point1)
                let line2 = Line(from: arc.point2, to: point2)
                let arc = Arc(center: arc.vertext, radius: 20, point1: arc.point1, point2: arc.point2)
                line1.stroke()
                line2.stroke()
                context.setLineDash(phase: 0, lengths: [2, 2])
                arc.stroke(pie: true)
                context.setLineDash(phase: 0, lengths: [])
            }
        } else if let crossPoint = crossPoint {
            context.setLineDash(phase: 0, lengths: [2, 2])
            Line(from: points[0][0], to: crossPoint).stroke()
            Line(from: points[1][0], to: crossPoint).stroke()
            context.setLineDash(phase: 0, lengths: [])
        }
        
        super.draw()
    }
    
    // MARK: - Path
    
    public override func path() -> CGPath? {
        guard isCompleted else { return nil }
        let path = CGMutablePath()
        
        for section in points {
            path.addLines(between: section)
        }
        
        for arc in arcs {
            let line1 = Line(from: arc.vertext, to: arc.point1)
            let line2 = Line(from: arc.vertext, to: arc.point2)
            let arc = Arc(center: arc.vertext, radius: 20,
                          point1: arc.point1, point2: arc.point2)
            path.addLine(line1)
            path.addLine(line2)
            path.addArc(arc, pie: true)
        }
        
        return path
    }
    
}
