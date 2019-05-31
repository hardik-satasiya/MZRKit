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
        updateRotationSlider()
        
        mzrView.delegate = self
        mzrView.scaleStyle = .cross(10, .center, .by10)
    }
    
    func updateRotationSlider() {
        if let item = mzrView.selectedItems.first, mzrView.selectedItems.count == 1 {
            let degree = 360 - MZRDegreeFromRadian(item.rotation)
            rotationSlider.doubleValue = Double(degree)
            rotationSlider.isEnabled = true
        } else {
            rotationSlider.doubleValue = 0
            rotationSlider.isEnabled = false
        }
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
        
        switch mzrView.scaleStyle {
        case .cross(_, let origin, let div):
            mzrView.scaleStyle = .cross(CGFloat(doubleValue), origin, div)
        default:
            break
        }
    }
    
    @IBAction func scaleOriginChanged(_ sender: NSPopUpButton) {
        switch mzrView.scaleStyle {
        case .cross(let val, _, let div):
            let origin = MZRView.ScaleStyle.Origin(rawValue: sender.indexOfSelectedItem)!
            mzrView.scaleStyle = .cross(val, origin, div)
        default:
            break
        }
    }
    
    @IBAction func makeItem(_ sender: Any) {
        mzrView.makeItem(MZRView.Item.allCases[itemListButton.indexOfSelectedItem])
    }
    
    @IBAction func rotationSliderValueChanged(_ sender: NSSlider) {
        guard mzrView.selectedItems.count == 1 else { return }
        let degree = CGFloat(sender.doubleValue)
        let radian = MZRRadianFromDegree(360 - degree)
        mzrView.rotateSelectedItems(radian)
    }
    
}

extension ViewController: MZRViewDelegate {
    
    func mzrView(_ mzrView: MZRView, didFinish item: MZRItem) {
        
    }
    
    func mzrView(_ mzrView: MZRView, didModified item: MZRItem) {
        
    }
    
    func mzrView(_ mzrView: MZRView, didSelect items: [MZRItem]) {
        updateRotationSlider()
    }
    
    func mzrView(_ mzrView: MZRView, didDeselect items: [MZRItem]) {
        updateRotationSlider()
    }
    
}
