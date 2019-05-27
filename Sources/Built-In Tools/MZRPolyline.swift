//
//  MZRPolyline.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRPolyline: MZRItem, DistanceMeasurable {
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            var distances = [CGFloat]()
            var lastPoint: CGPoint?
            
            for point in self.points.flatMap({$0}) {
                if let lastPoint = lastPoint {
                    let line = Line(from: lastPoint, to: point)
                    
                    distances.append(line.distance)
                } else {
                    lastPoint = point
                }
            }
            self.distances = distances
        }
    }
    
    // MARK: - DistanceMeasurable
    
    public private(set) var distances: [CGFloat] = []
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(.inf(continuous: false, canCut: false))
    }
    
}
