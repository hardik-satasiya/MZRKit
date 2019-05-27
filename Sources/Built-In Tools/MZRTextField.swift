//
//  MZRTextField.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/23.
//

import Foundation

public class MZRTextField: MZRRect {
    
    public var attributedString = NSAttributedString(string: "Text")
    
    // MARK: - Drawing
    
    public override func draw() {
        guard let context = CGContext.current, isCompleted else { return }
        
        context.saveGState()
        defer {  }
        // Transform
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: points[0][0].x, y: points[0][0].y)
        transform = transform.rotated(by: rotation)
        context.concatenate(transform)
        // Draw rect
        var dx = width / 2 - attributedString.size().width / 2
        var dy = -height / 2 - attributedString.size().height / 2
        var clipRect = CGRect(x: 0, y: -height, width: width, height: height)
        
        if flip.contains(.horizontal) {
            dx -= width
            clipRect.origin.x = -width
        }
        
        if flip.contains(.vertical) {
            dy += height
            clipRect.origin.y = 0
        }
        
        context.clip(to: clipRect)
        attributedString.draw(at: CGPoint(x: dx, y: dy))
        context.restoreGState()
        super.draw()
    }
    
}
