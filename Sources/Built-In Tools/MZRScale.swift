//
//  MZRScale.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/27.
//

import Foundation

class MZRScale {
    
    // MARK: - Settings
    
//    public var scaleStyle = ScaleStyle.grid(2)
//        ScaleStyle.cross(10, .leftTop, .by10)
    
    public var scaleOrigin = ScaleOrigin.center
    
    public var fov = CGFloat(0)
    
    public var division = ScaleDivision.by10
    
    public var scaleColor = MZRColor.green
    
    // MARK: - Internal Drawing
    
    private func drawCross(rect: CGRect, value: CGFloat, origin: ScaleOrigin, division: ScaleDivision) {
        guard let context = CGContext.current, value > 0 else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        context.setStrokeColor(scaleColor.cgColor)
        
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
    
//    private func drawGrid(rect: CGRect, value: Int) {
//        guard let context = CGContext.current, value > 1 else { return }
//
//        context.saveGState()
//        defer { context.restoreGState() }
//        context.setStrokeColor(scaleColor.cgColor)
//
//        let width = rect.width / CGFloat(value)
//        let height = rect.height / CGFloat(value)
//
//        for i in 1..<value {
//            Line(from: CGPoint(x: width * CGFloat(i), y: 0), to: CGPoint(x: width * CGFloat(i), y: rect.maxY)).stroke()
//            Line(from: CGPoint(x: 0, y: height * CGFloat(i)), to: CGPoint(x: rect.maxX, y: height * CGFloat(i))).stroke()
//        }
//    }
    
    public func draw(_ rect: CGRect) {
//        switch scaleStyle {
//        case .cross(let value, let origin, let div): drawCross(rect: rect, value: value, origin: origin, division: div)
//        case .grid(let value): drawGrid(rect: rect, value: value)
//        }
        drawCross(rect: rect, value: fov, origin: scaleOrigin, division: division)
    }
    
}
