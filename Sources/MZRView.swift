//
//  MZRView.swift
//  MZRKit
//
//  Created by scchnxx on 2019/5/21.
//

import Foundation

public protocol MZRViewDelegate: AnyObject {
    
    func mzrView(_ mzrView: MZRView, finishing item: MZRItem)
    
    func mzrView(_ mzrView: MZRView, didFinish item: MZRItem)
    
    func mzrView(_ mzrView: MZRView, didModified item: MZRItem)
    
    func mzrView(_ mzrView: MZRView, didSelect items: [MZRItem])
    
    func mzrView(_ mzrView: MZRView, didDeselect items: [MZRItem])
    
}

extension MZRView {
    
    public enum Item: Int, CaseIterable {
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
    
}

#if os(OSX)

public class MZRView: NSView {
    
    public weak var delegate: MZRViewDelegate?
    
    let viewModel = MZRViewModel()
    
    public init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    public override func layout() {
        viewModel.fieldSize = bounds.size
        super.layout()
    }
    
    // MARK: - Mouse Events
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let point = convert(event.locationInWindow, from: nil)
        window?.makeFirstResponder(nil)
        viewModel.began(point)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let point = convert(event.locationInWindow, from: nil)
        viewModel.moved(point)
    }
    
    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        let point = convert(event.locationInWindow, from: nil)
        viewModel.ended(point)
    }
    
}

#else

public class MZRView: UIView {
    
    public weak var delegate: MZRViewDelegate?
    
    let viewModel = MZRViewModel()
    
    public init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    public override func layoutSubviews() {
        viewModel.fieldSize = bounds.size
        super.layoutSubviews()
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
    
    private func commonDisplay() {
        #if os(OSX)
        self.needsDisplay = true
        #else
        self.setNeedsDisplay()
        #endif
    }
    
    private func commonInit() {
        viewModel.shouldUpdate = { [unowned self] in
            self.commonDisplay()
        }
        
        viewModel.finishingItem = { [unowned self] item in
            self.delegate?.mzrView(self, finishing: item)
        }
        
        viewModel.itemFinished = { [unowned self] item in
            self.delegate?.mzrView(self, didFinish: item)
        }
        
        viewModel.itemModified = { [unowned self] item in
            self.delegate?.mzrView(self, didModified: item)
        }
        
        viewModel.itemsSelected = { [unowned self] items in
            self.delegate?.mzrView(self, didSelect: items)
        }
        
        viewModel.itemsDeselected = { [unowned self] items in
            self.delegate?.mzrView(self, didDeselect: items)
        }
    }
    
    public override func draw(_ dirtyRect: CGRect) {
        viewModel.draw(bounds)
    }
    
    // MARK: - Interface
    
    public var state: State {
        return viewModel.state
    }
    
    /// Returns all complted items.
    public var items: [MZRItem] {
        get { return viewModel.items }
        set {
            viewModel.items = newValue.filter({ $0.isCompleted })
            commonDisplay()
        }
    }
    
    /// Returns the selected items.
    public var selectedItems: [MZRItem] {
        get { return viewModel.selectedItems }
        set {
            viewModel.selectedItems = newValue.filter({ items.contains($0) })
            commonDisplay()
        }
    }
    
    /// A Boolean value indicates item rotation is enabled.
    public var isRotatorEnabled: Bool {
        get { return viewModel.rotatorEnabled }
        set { viewModel.rotatorEnabled = newValue }
    }
    
    // MARK: Color Settings
    
    /// Returns the current drawing color.
    ///
    /// Set this value will also update the colors of the selected items.
    public var drawingColor: MZRColor {
        get { return viewModel.drawingColor }
        set { viewModel.drawingColor = newValue }
    }
    
    /// Scale color.
    public var scaleColor: MZRColor {
        get { return viewModel.scaleColor }
        set { viewModel.scaleColor = newValue }
    }
    
    /// Border color of selection rectangle.
    public var selectionBorderColor: MZRColor {
        get { return viewModel.selectionBorderColor }
        set { viewModel.selectionBorderColor = newValue }
    }
    
    /// Background color of selection rectangle.
    public var selectionBackgroundColor: MZRColor {
        get { return viewModel.selectionBackgroundColor }
        set { viewModel.selectionBackgroundColor = newValue }
    }
    
    /// Returns the crosshair scale origin.
    public var scaleOrigin: ScaleOrigin? {
        guard case .cross(_, let origin, _) = scaleStyle else { return nil }
        return origin
    }
    
    /// Returns the crosshair scale bar division.
    public var scaleDivision: ScaleDivision? {
        guard case .cross(_, _, let div) = scaleStyle else { return nil }
        return div
    }
    
    /// Returns the number of grid scale.
    public var numberOfScaleGrids: Int? {
        guard case .grid(let num) = scaleStyle else { return nil }
        return num
    }
    
    /// Scale style.
    ///
    /// `MZRView` provides 2 diferrent scale styles:
    /// 1. Cross Hair (FOV, Origin, Number of Bar)
    /// 2. Grid (Number of grids)
    public var scaleStyle: ScaleStyle {
        get {
            return viewModel.scale.scaleStyle
        }
        set {
            viewModel.scale.scaleStyle = newValue
            commonDisplay()
        }
    }
    
    /// Begin a drawing session  with `Item`.
    public func makeItem(_ item: Item) {
        viewModel.makeItem(type: item.itemType)
    }
    
    /// Delete selection items.
    public func deleteSelectedItems() {
        var newItems = viewModel.items
        for item in viewModel.selectedItems {
            guard let index = newItems.firstIndex(of: item) else { continue }
            newItems.remove(at: index)
        }
        viewModel.items = newItems
    }
    
    /// Rotate selected item if `rotatorEnabled` is `true`.
    public func rotate(_ radian: CGFloat) {
        guard isRotatorEnabled else { return }
        viewModel.rotate(radian)
    }
    
    /// Become selection mode.
    public func normal() {
        viewModel.normal()
    }
    
    /// Returns the item at the specified location.
    public func item(at location: CGPoint) -> MZRItem? {
        return viewModel.item(at: location)
    }
    
    /// Returns a tuple contains the item and the position of the point the specified location lies in.
    public func positionForItem(at location: CGPoint) -> (MZRItem, MZRItem.Position)? {
        return viewModel.positionForItem(at: location)
    }
    
}
