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
            shouldUpdate?()
        }
    }
    
    // MARK: - Settings
    
    var outlineWidth = CGFloat(5)
    
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
    
    private func makeOutlinePath(_ path: CGPath) -> CGPath {
        return path.copy(strokingWithWidth: outlineWidth,
                         lineCap: .round, lineJoin: .round, miterLimit: 10)
    }
    
    private func item(at location: CGPoint) -> MZRItem? {
        return { () -> MZRItem? in
            return items.reversed().first(where: { item in
                guard let path = item.path() else { return false }
                return makeOutlinePath(path).contains(location)
            })
        }()
    }
    
    /// Returns item and position of a non inf size selected item or nil if nothing is selected.
    private func position(at location: CGPoint) -> (MZRItem, MZRItem.Position)? {
        guard let selectedItem = selectedItems.first, selectedItems.count == 1 else { return nil }
        if case .inf(let continuous, _) = selectedItem.size, continuous {
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
    
    // MARK: - Life Cycle
    
    init() {
        test()
    }
    
    func test() {
        makeItem(type: MZRRect.self)
    }
    
    // MARK: - Make Item
    
    func makeItem(type: MZRItem.Type) {
        normal()
        mode = .drawing(item: type.init(), pressed: false)
    }
    
    /// Become selection mode.
    func normal() {
        if case .drawing(let item, _) = mode {
            if item.isCompleted, item.points.flatMap({ $0 }).count > 1 {
                items.append(item)
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
            case .std(_, let row) :
                guard item.points.isEmpty || item.points.last?.count == row else { break }
                item.addPoint(location)
            
            case .inf(continuous: let continuous, canCut: _):
                guard !continuous, item.points.isEmpty else { break }
                item.addPoint(location)
            }
            
            item.addPoint(location)
            mode = .drawing(item: item, pressed: true)
            
        case .select:
            if let (item, position) = position(at: location) {
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
                if continuous {
                    item.addPoint(location)
                } else {
                    item.modifyPoint(location, at: (col, row))
                }
            }
            
        case .select(selectionMode: let selectionMode):
            switch selectionMode {
            case .onItem:
                mode = .select(selectionMode: .draggingItems)
                moved(location)
                return
                
            case .draggingItems:
                guard let lastLocation = lastLocation else { break }
                let offset = CGPoint(x: location.x - lastLocation.x, y: location.y - lastLocation.y)
                for item in selectedItems {
                    item.offset(x: offset.x, y: offset.y)
                }
                
            case .onPoint(item: let item, position: let position):
                mode = .select(selectionMode: .draggingPoint(item: item, position: position))
                moved(location)
                return
                
            case .draggingPoint(item: let item, position: let position):
                guard let lastLocation = lastLocation else { break }
                let offset = CGPoint(x: location.x - lastLocation.x, y: location.y - lastLocation.y)
                item.offset(x: offset.x, y: offset.y, at: position)
                
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
            case .std:
                guard item.isCompleted else { break }
                items.append(item)
                mode = .select(selectionMode: .normal)
                
            case .inf(continuous: _, let canCut):
                guard canCut else { break }
                item.cut()
                mode = .drawing(item: item, pressed: false)
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
                guard let path = item.path() else { break }
                let boundingBox = path.boundingBox.insetBy(dx: -10, dy: -10)
                context.saveGState()
                context.setLineDash(phase: 0, lengths: [4, 4])
                context.addRect(boundingBox)
                context.strokePath()
                context.restoreGState()
            default:
                item.drawPoints()
            }
        }
    }
    
    func draw() {
        guard let context = CGContext.current else { return }
        
        let currentItem = { () -> [MZRItem] in
            guard case .drawing(let item, _) = mode else { return [] }
            return [item]
        }()
        
        for item in (items.reversed() + currentItem) {
            if item.isCompleted {
                item.draw()
                drawOutlineIfNeeded(item: item)
            } else {
                item.drawArch()
            }
        }
        
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
