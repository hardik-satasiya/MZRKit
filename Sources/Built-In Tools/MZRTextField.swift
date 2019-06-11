//
//  MZRTextField.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/23.
//

import Foundation

public class MZRTextField: MZRRect {
    
    public var attributedString = NSAttributedString(string: "Text")
    
    public var backgroundColor = MZRColor.clear
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current, let anchorPoint = anchorPoint() else { return }
        context.saveGState()
        context.translateBy(x: anchorPoint.x, y: anchorPoint.y)
        context.rotate(by: rotation)
        
        let unrotated_p0 = points[0][0].rotated(center: anchorPoint, angle: -rotation)
        let p0 = CGPoint(x: unrotated_p0.x - anchorPoint.x, y: unrotated_p0.y - anchorPoint.y)
        let textSize = attributedString.size()
        var dx = p0.x + width / 2 - textSize.width / 2
        var dy = p0.y - height / 2 - textSize.height / 2
        var clipRect = CGRect(x: p0.x, y: p0.y - height, width: width, height: height)

        if flip.contains(.horizontal) {
            dx -= width
            clipRect.origin.x -= width
        }
        if flip.contains(.vertical) {
            dy += height
            clipRect.origin.y += height
        }
        
        context.clip(to: clipRect)
        context.addRect(clipRect)
        context.setFillColor(backgroundColor.cgColor)
        context.fillPath()
        attributedString.draw(at: CGPoint(x: dx, y: dy))
        context.restoreGState()
        
        super.draw()
    }
    
}
