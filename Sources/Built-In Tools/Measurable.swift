//
//  Measurable.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/22.
//

import Foundation


public protocol Measurable {
    
}

public protocol DistanceMeasurable: Measurable {
    var distances: [CGFloat] { get }
}

public protocol RectangleMeasurable: Measurable {
    var width:  CGFloat { get }
    var height: CGFloat { get }
}

public protocol CircleMeasurable: Measurable {
    var radius: CGFloat { get }
    var center: CGPoint { get }
}

public protocol AngleMeasurable1: Measurable {
    var angle: CGFloat { get }
}

public protocol AngleMeasurable2: Measurable {
    var acuteAngle:  CGFloat { get }
    var obtuseAngle: CGFloat { get }
}

protocol LineTrackable: MZRItem {
    var tracker: MZRLine? { get set }
    var trackerPosition: Position { get set }
    var trackedPoint: CGPoint { get }
    
    func canSetTracker(_ line: MZRLine, at position: Position) -> Bool
    func setTracker(_ line: MZRLine, position: MZRItem.Position)
    func removeTracker()
    func updateTracker()
}

extension LineTrackable {
    
    func canSetTracker(_ line: MZRLine, at position: Position) -> Bool {
        Line(from: line.points[position.0][position.1], to: trackedPoint).distance <= 10
    }
    
    func setTracker(_ line: MZRLine, position: Position) {
        tracker = line
        trackerPosition = position
        updateTracker()
    }
    
    func removeTracker() {
        tracker = nil
    }
    
    func updateTracker() {
        guard isCompleted, let tracker = tracker else { return }
        tracker.modifyPoint(trackedPoint, at: trackerPosition)
    }
    
}
