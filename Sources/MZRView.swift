//
//  MZRView.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

import Foundation

extension MZRView {
    
    public enum Item: CaseIterable {
        // Ruler
        case line
        case polyline
        // Rect
        case rect
        case square
        // Circular
        case circle1
        case circle2
        // Degree
        case angle1
        case angle2
        case angle3
        // Drawing
        case pencil
        // Text
        case textField
        
        fileprivate var itemType: MZRItem.Type {
            switch self {
            case .line:      return MZRLine.self
            case .polyline:  return MZRPolyline.self
            case .rect:      return MZRRect.self
            case .square:    return MZRSquare.self
            case .circle1:   return MZRCircle1.self
            case .circle2:   return MZRCircle2.self
            case .angle1:    return MZRAngle1.self
            case .angle2:    return MZRAngle2.self
            case .angle3:    return MZRAngle3.self
            case .pencil:    return MZRPencil.self
            case .textField: return MZRTextField.self
            }
        }
    }
    
    // MARK: - Scale Options
    
    public enum Origin: Int {
        case center
        #if os(OSX)
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
        #else
        case leftBottom
        case rightBottom
        case leftTop
        case rightTop
        #endif
    }
    
    public enum Division: Int {
        case by10
        case by5
        case by1
    }
    
    public enum ScaleStyle {
        case cross(CGFloat, Origin, Division)
        case grid(Int)
    }
    
}

#if os(OSX)

public class MZRView: NSView {
    
    let viewModel = MZRViewModel()
    
    public init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    // MARK: - Mouse Events
    
    public override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        viewModel.began(point)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        viewModel.moved(point)
    }
    
    public override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        viewModel.ended(point)
    }
    
}

#else

public class MZRView: UIView {
    
    let viewModel = MZRViewModel()
    
    public init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    // MARK: - Touch Events
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), touches.count == 1 else { return }
        viewModel.began(point)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), touches.count == 1 else { return }
        viewModel.moved(point)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), touches.count == 1 else { return }
        viewModel.ended(point)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), touches.count == 1 else { return }
        viewModel.ended(point)
    }
    
}

#endif

extension MZRView {
    
    // MARK: - Internal Methods
    
    private func refresh() {
        #if os(OSX)
        self.needsDisplay = true
        #else
        self.setNeedsDisplay()
        #endif
    }
    
    private func commonInit() {
        viewModel.shouldUpdate = { [unowned self] in
            self.refresh()
        }
    }
    
    public override func draw(_ dirtyRect: CGRect) {
        viewModel.draw(dirtyRect)
    }
    
    // MARK: - Interface
    
    public var items: [MZRItem] {
        get {
            return viewModel.items
        }
        set {
            viewModel.items = newValue
        }
    }
    
    public var selectedItems: [MZRItem] {
        get {
            return viewModel.selectedItems
        }
        set {
            viewModel.selectedItems = newValue
        }
    }
    
    public var scaleStyle: ScaleStyle {
        get {
            switch viewModel.scale.scaleStyle {
            case .cross(let value, let origin, let div):
                return .cross(value, Origin(rawValue: origin.rawValue)!, Division(rawValue: div.rawValue)!)
                
            case .grid(let value):
                return .grid(value)
            }
        }
        set {
            switch newValue {
            case .cross(let value, let origin, let div):
                viewModel.scale.scaleStyle = .cross(value,
                                                    MZRScale.Origin(rawValue: origin.rawValue)!,
                                                    MZRScale.Division(rawValue: div.rawValue)!)
                
            case .grid(let value):
                viewModel.scale.scaleStyle = .grid(value)
            }
            refresh()
        }
    }
    
    public func makeItem(_ item: Item) {
        viewModel.makeItem(type: item.itemType)
    }
    
    public func deleteSelectedItems() {
        var newItems = viewModel.items
        for item in viewModel.selectedItems {
            guard let index = newItems.firstIndex(of: item) else { continue }
            newItems.remove(at: index)
        }
        viewModel.items = newItems
    }
    
    public func rotateSelecteditems(_ radian: CGFloat) {
        viewModel.rotate(radian)
    }
    
    public func normal() {
        viewModel.normal()
    }
    
}
