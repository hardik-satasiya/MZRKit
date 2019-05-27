//
//  MZRLine.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

public class MZRLine: MZRItem, DistanceMeasurable {
    
    private var line: Line?
    
    public internal(set) override var points: [[CGPoint]] {
        didSet {
            guard isCompleted else { return }
            line = Line(from: points[0][0], to: points[0][1])
        }
    }
    
    // MARK: - DistanceMeasurable
    
    public var distances: [CGFloat] {
        return [line?.distance ?? 0]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(Size.std(1, 2))
    }
    
}
