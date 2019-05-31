//
//  MZRScale.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/27.
//

import Foundation

extension MZRScale {
    
    public enum Origin: Int {
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
    
    public enum Division: Int {
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
        case cross(CGFloat, Origin, Division)
        case grid(Int)
    }
    
}

class MZRScale {
    
    // MARK: - Settings
    
    public var scaleStyle =
        ScaleStyle.grid(2)
//        ScaleStyle.cross(10, .leftTop, .by10)
    
    public var scaleColor = MZRMakeCGColor(r: 0, g: 1, b: 0, a: 1)
    
    // MARK: - Internal Drawing
    
    private func drawCross(rect: CGRect, value: CGFloat, origin: Origin, division: Division) {
        guard let context = CGContext.current, value > 0 else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        context.setStrokeColor(scaleColor)
        
        let directions: [(x: CGFloat, y: CGFloat)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        let pOrigin = origin.location(rect)
        let step = rect.width / value / division.bars
        
        for direction in directions {
            var current = pOrigin
            var i = 1
            
            while (current.x >= 0 && rect.maxX >= current.x) && (current.y >= 0 && rect.maxY >= current.y) {
                current = CGPoint(x: current.x + direction.x * step, y: current.y + direction.y * step)
                
                let len = division.length(at: i)
                let lenX = direction.y * len
                let lenY = direction.x * len
                Line(from: CGPoint(x: current.x - lenX, y: current.y + lenY),
                     to: CGPoint(x: current.x + lenX, y: current.y - lenY)).stroke()
                i += 1
            }
        }
        
        Line(from: CGPoint(x: pOrigin.x, y: 0), to: CGPoint(x: pOrigin.x, y: rect.maxY)).stroke()
        Line(from: CGPoint(x: 0, y: pOrigin.y), to: CGPoint(x: rect.maxX, y: pOrigin.y)).stroke()
    }
    
    private func drawGrid(rect: CGRect, value: Int) {
        guard let context = CGContext.current, value > 1 else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        context.setStrokeColor(scaleColor)
        
        let width = rect.width / CGFloat(value)
        let height = rect.height / CGFloat(value)
        
        for i in 1..<value {
            Line(from: CGPoint(x: width * CGFloat(i), y: 0), to: CGPoint(x: width * CGFloat(i), y: rect.maxY)).stroke()
            Line(from: CGPoint(x: 0, y: height * CGFloat(i)), to: CGPoint(x: rect.maxX, y: height * CGFloat(i))).stroke()
        }
    }
    
    public func draw(_ rect: CGRect) {
        switch scaleStyle {
        case .cross(let value, let origin, let div): drawCross(rect: rect, value: value, origin: origin, division: div)
        case .grid(let value): drawGrid(rect: rect, value: value)
        }
    }
    
}
