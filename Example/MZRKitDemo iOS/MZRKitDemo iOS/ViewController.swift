//
//  ViewController.swift
//  MZRKitDemo iOS
//
//  Created by scchnxx on 2019/4/5.
//  Copyright © 2019 scchnxx. All rights reserved.
//

import UIKit
import MZRKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

class MyView: UIView {
    
    override func draw(_ dirtyRect: CGRect) {
        let context = CGContext.current!
        let center = CGPoint(x: 100, y: 100)
        let point1 = CGPoint(x: 150, y: 150)
        let point2 = CGPoint(x: 150, y: 5)
        let arc = Arc(center: center, radius: 50, point1: point1, point2: point2)
        
        context.addLines(between: [point1, center, point2])
        context.strokePath()
        context.addArc(center: arc.center, radius: arc.radius,
                       startAngle: arc.startAngle, endAngle: arc.endAngle,
                       clockwise: arc.clockwise)
        context.strokePath()
    }
    
}
