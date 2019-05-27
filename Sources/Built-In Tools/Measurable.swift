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
