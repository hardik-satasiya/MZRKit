//
//  MZRViewModel.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/5.
//

extension MZRViewModel {
    
    enum Mode {
        case drawing(item: MZRItem, pressed :Bool)
        case select(selectionMode: SelectionMode)
    }
    
    enum SelectionMode {
        case normal
        case onItem(item: MZRItem)
        case onPoint(item: MZRItem, position: MZRItem.Position)
        case draggingItems
        case draggingPoint(item: MZRItem, position: MZRItem.Position)
    }
    
}

class MZRViewModel {
    
    private var mode = Mode.select(selectionMode: .normal)
    
    private var selectionRect = CGRect.null
    
    private var lastLocation: CGPoint?
    
    private var rotator: MZRRotator?
    
    // MARK: - Item
    
    var items = [MZRItem]() {
        didSet {
            let old = Set(oldValue)
            let new = Set(items)
            let selection = Set(selectedItems)
            let deleteds = old.subtracting(new)
            let deletedSelections = selection.intersection(deleteds)
            
            if !deletedSelections.isEmpty {
                var newSelection = selectedItems
                for deletedSelection in deletedSelections {
                    guard let index = newSelection.firstIndex(of: deletedSelection) else { continue }
                    newSelection.remove(at: index)
                }
                selectedItems = newSelection
            } else {
                shouldUpdate?()
            }
        }
    }
    
    var selectedItems = [MZRItem]() {
        didSet {
            updateRotator()
            shouldUpdate?()
        }
    }
    
    var scale = MZRScale()
    
    // MARK: - Settings
    
    var rotatorEnabled = true {
        didSet {
            updateRotator()
            shouldUpdate?()
        }
    }
    
    var outlineWidth = CGFloat(10)
    
    var pointOutline = CGFloat(10)
    
    var oulineColor = MZRMakeCGColor(r: 0, g: 1, b: 1, a: 1)
    
    var selectionColors: (border: CGColor, background: CGColor) = (
        MZRMakeCGColor(r: 1, g: 1, b: 1, a: 1),
        MZRMakeCGColor(r: 0.3, g: 0.5, b: 0.5, a: 0.5)
    ) {
        didSet {
            shouldUpdate?()
        }
    }
    
    // MARK: - Getters
    
    /// Selected items > unselected items.
    private func sortedItems() -> [MZRItem] {
        let selecteds = selectedItems.reversed()
        let others = Set(items).subtracting(selecteds)
        return selecteds + others.sorted { self.items.firstIndex(of: $0)! > self.items.firstIndex(of: $1)! }
    }
    
    private func outlinePath(item: MZRItem) -> CGPath? {
        guard let path = item.path() else { return nil }
        switch item.size {
        case .inf(continuous: let continuous, canCut: _) where continuous:
            let boundingBox = path.boundingBox.insetBy(dx: -10, dy: -10)
            return CGPath(rect: boundingBox, transform: nil)
        default:
            return path.copy(strokingWithWidth: outlineWidth, lineCap: .round, lineJoin: .round, miterLimit: 10)
        }
    }
    
    private func item(at location: CGPoint) -> MZRItem? {
        let items = sortedItems()
        guard let index = items.compactMap(outlinePath).firstIndex(where: { $0.contains(location) }) else { return nil }
        return items[index]
    }
    
    /// Returns item and position of a non `inf` size selected item or nil if nothing is selected.
    private func itemPosition(at location: CGPoint) -> (MZRItem, MZRItem.Position)? {
        guard let selectedItem = selectedItems.first, selectedItems.count == 1 else { return nil }
        
        if let rotator = rotator, rotator.contains(location) {
            return (rotator, (0, 0))
        } else if case .inf(let continuous, _) = selectedItem.size, continuous {
            return nil
        }
        
        for (col, section) in selectedItem.points.enumerated() {
            for (row, point) in section.enumerated() {
                if Line(from: point, to: location).distance < pointOutline {
                    return (selectedItem, (col, row))
                }
            }
        }
        return nil
    }
    
    // MARK: - Event
    
    var shouldUpdate: (() -> Void)?
    
    var itemFinished: ((MZRItem) -> Void)?
    
    var itemModified: ((MZRItem) -> Void)?
    
    // MARK: - Life Cycle
    
    init() {
        test()
    }
    
    func test() {
        makeItem(type: MZRRect.self)
    }
    
    // MARK: - Item
    
    private func updateRotator() {
        if let item = selectedItems.first, selectedItems.count == 1, rotatorEnabled {
            rotator = MZRRotator(target: item)
        } else {
            rotator = nil
        }
    }
    
    func makeItem(type: MZRItem.Type) {
        normal()
        mode = .drawing(item: type.init(), pressed: false)
    }
    
    /// Become selection mode.
    func normal() {
        if case .drawing(let item, _) = mode {
            if item.isCompleted, item.points.flatMap({ $0 }).count > 1 {
                items.append(item)
                itemFinished?(item)
            }
        }

        selectedItems = []
        mode = .select(selectionMode: .normal)
    }
    
    /// Rotate selected items with `radian`
    func rotate(_ radian: CGFloat) {
        for item in selectedItems {
            item.rotation = radian
        }
        shouldUpdate?()
    }
    
    // MARK: - Mouse / Touch Events
    
    func began(_ location: CGPoint) {
        switch mode {
        case .drawing(item: let item, pressed: _):
            switch item.size {
            case .std(_, let row) where item.points.isEmpty || item.points.last?.count == row:
                item.addPoint(location)
                
            case .inf(continuous: let continuous, canCut: _) where !continuous && item.points.isEmpty:
                item.addPoint(location)
                
            default: break
            }
            
            item.addPoint(location)
            mode = .drawing(item: item, pressed: true)
            
        case .select:
            if let (item, position) = itemPosition(at: location) {
                mode = .select(selectionMode: .onPoint(item: item, position: position))
            } else if let item = item(at: location) {
                if !selectedItems.contains(item) {
                    selectedItems = [item]
                }
                mode = .select(selectionMode: .onItem(item: item))
            } else {
                selectedItems = []
                selectionRect.origin = CGPoint(x: round(location.x) + 0.5, y: round(location.y) + 0.5)
            }
        }
        
        lastLocation = location
        shouldUpdate?()
    }
    
    func moved(_ location: CGPoint) {
        switch mode {
        case .drawing(item: let item, pressed: _):
            let col = item.points.count - 1
            let row = item.points.last!.count - 1
            
            switch item.size {
            case .std:
                item.modifyPoint(location, at: (col, row))
                
            case .inf(continuous: let continuous, canCut: _):
                continuous ? item.addPoint(location) : item.modifyPoint(location, at: (col, row))
            }
            
        case .select(selectionMode: let selectionMode):
            switch selectionMode {
            case .onItem:
                mode = .select(selectionMode: .draggingItems)
                moved(location)
                return
                
            case .onPoint(item: let item, position: let position):
                mode = .select(selectionMode: .draggingPoint(item: item, position: position))
                moved(location)
                return
                
            case .draggingItems:
                guard let lastLocation = lastLocation else { break }
                let offset = CGPoint(x: location.x - lastLocation.x, y: location.y - lastLocation.y)
                for item in selectedItems {
                    item.offset(x: offset.x, y: offset.y)
                }
                // update rotato
                if let rotator = rotator, let anchorPoint = rotator.targetItem?.anchorPoint() {
                    rotator.points[0][0] = anchorPoint
                }
                
            case .draggingPoint(item: let item, position: let position):
                item.modifyPoint(location, at: position)
                // update rotato
                if item != rotator {
                    if let rotator = rotator, let anchorPoint = rotator.targetItem?.anchorPoint() {
                        rotator.points[0][0] = anchorPoint
                    }
                    
                    itemModified?(item)
                }
                
            default:
                let width = round(location.x - selectionRect.origin.x)
                let height = round(location.y - selectionRect.origin.y)
                selectionRect.size = CGSize(width: width, height: height)
                selectedItems = items.filter({ $0.canSelected(by: selectionRect) })
            }
        }
        
        lastLocation = location
        shouldUpdate?()
    }
    
    func ended(_ location: CGPoint) {
        switch mode {
        case .drawing(item: let item, pressed: _):
            switch item.size {
            case .std where item.isCompleted:
                items.append(item)
                mode = .select(selectionMode: .normal)
                itemFinished?(item)
                
            case .inf(continuous: _, let canCut) where canCut:
                item.cut()
                mode = .drawing(item: item, pressed: false)
                
            default: break
            }
            
        case .select(selectionMode: let selectionMode):
            if case .onItem(let item) = selectionMode {
                selectedItems = [item]
            }
            selectionRect = .null
            mode = .select(selectionMode: .normal)
        }
        
        lastLocation = nil
        shouldUpdate?()
    }
    
    // MARK: - Drawing
    
    private func drawOutlineIfNeeded(item: MZRItem) {
        guard let context = CGContext.current else { return }
        guard case .select(let selectionMode) = mode, selectedItems.contains(item) else { return }
        
        switch selectionMode {
        case .draggingItems, .draggingPoint:
            break
            
        case .onPoint(item: let item, position: let pos):
            item.drawPoints(marked: [pos])
            
        default:
            switch item.size {
            case .inf(continuous: let continuous, canCut: _) where continuous:
                guard let path = outlinePath(item: item) else { break }
                context.saveGState()
                context.setLineDash(phase: 0, lengths: [4, 4])
                context.addPath(path)
                context.strokePath()
                context.restoreGState()
            default:
                item.drawPoints()
            }
        }
    }
    
    func draw(_ rect: CGRect) {
        guard let context = CGContext.current else { return }
        
        let currentItem = { () -> [MZRItem] in
            guard case .drawing(let item, _) = mode else { return [] }
            return [item]
        }()
        
        scale.draw(rect)
        
        for item in (sortedItems() + currentItem) {
            if item.isCompleted {
                item.draw()
                drawOutlineIfNeeded(item: item)
            } else {
                item.drawArch()
            }
        }
        
        rotator?.draw()
        
        if selectionRect != .null {
            context.setFillColor(selectionColors.background)
            context.setStrokeColor(selectionColors.border)
            
            context.addRect(selectionRect)
            context.fillPath()
            context.addRect(selectionRect)
            context.strokePath()
        }
    }
    
}
