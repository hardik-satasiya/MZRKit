//
//  ScaleStyle.swift
//  MZRKit
//
//  Created by 陳世爵 on 2019/6/12.
//

import Foundation

public enum ScaleOrigin: Int {
    case center
    case leftTop
    case leftBottom
    case rightTop
    case rightBottom
    
    func location(_ field: CGRect) -> CGPoint {
        #if os(OSX)
        switch self {
        case .center:      return .init(x: field.midX, y: field.midY)
        case .leftTop:     return .init(x: field.minX, y: field.maxY)
        case .leftBottom:  return .init(x: field.minX, y: field.minY)
        case .rightTop:    return .init(x: field.maxX, y: field.maxY)
        case .rightBottom: return .init(x: field.maxX, y: field.minY)
        }
        #else
        switch self {
        case .center:      return .init(x: field.midX, y: field.midY)
        case .leftTop:     return .init(x: field.minX, y: field.minY)
        case .leftBottom:  return .init(x: field.minX, y: field.maxY)
        case .rightTop:    return .init(x: field.maxX, y: field.minY)
        case .rightBottom: return .init(x: field.maxX, y: field.maxY)
        }
        #endif
    }
}

public enum ScaleDivision: Int {
    case by10
    case by5
    case by1
    
    var bars: CGFloat {
        switch self {
        case .by10: return 10
        case .by5: return 5
        case .by1: return 1
        }
    }
    
    func length(at index: Int) -> CGFloat {
        switch self {
        case .by10: return (index % 10 == 0) ? 15 : ((index % 5 == 0) ? 10 : 5)
        case .by5: return (index % 5 == 0) ? 15 : 10
        case .by1: return 10
        }
    }
}

public enum ScaleStyle {
    case cross(CGFloat, ScaleOrigin, ScaleDivision)
    case grid(Int)
}
