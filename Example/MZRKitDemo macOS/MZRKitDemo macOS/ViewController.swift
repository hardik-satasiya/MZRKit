//
//  ViewController.swift
//  MZRKitDemo macOS
//
//  Created by scchnxx on 2019/4/5.
//  Copyright © 2019 scchnxx. All rights reserved.
//

import Cocoa
import MZRKit

extension MZRView.Item: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .line:      return "line"
        case .polyline:  return "Polyline"
        case .rect:      return "Rect"
        case .square:    return "Square"
        case .circle1:   return "Circle1"
        case .circle2:   return "Circle2"
        case .angle1:    return "Angle1"
        case .angle2:    return "Angle2"
        case .angle3:    return "Angle3"
        case .pencil:    return "Pencil"
        case .textField: return "TextField"
        }
    }
    
}

class ViewController: NSViewController {
    
    @IBOutlet weak var mzrView: MZRView!
    @IBOutlet weak var itemListButton: NSPopUpButton!
    @IBOutlet weak var rotationSlider: NSSlider!
    @IBOutlet weak var scaleTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemListButton.removeAllItems()
        itemListButton.addItems(withTitles: MZRView.Item.allCases.map({ "\($0)" }))
    }
    
    @IBAction func normal(_ sender: Any) {
        mzrView.normal()
    }
    
    @IBAction func selectAllItems(_ sender: Any) {
        mzrView.selectedItems = mzrView.items
    }
    
    @IBAction func delete(_ sender: Any) {
        mzrView.deleteSelectedItems()
    }
    
    @IBAction func scaleTextFieldValueChanged(_ sender: NSTextField) {
        guard let doubleValue = Double(sender.stringValue) else { return }
        mzrView.scaleStyle = .cross(CGFloat(doubleValue), .center, .by10)
    }
    
    @IBAction func makeItem(_ sender: Any) {
        mzrView.makeItem(MZRView.Item.allCases[itemListButton.indexOfSelectedItem])
    }
    
    @IBAction func rotationSliderValueChanged(_ sender: NSSlider) {
        guard mzrView.selectedItems.count == 1 else { return }
        let degree = CGFloat(sender.doubleValue)
        let radian = MZRRadianFromDegree(degree)
        mzrView.rotateSelecteditems(radian)
    }
    
}
