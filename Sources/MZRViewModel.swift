//
//  MZRViewModel.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/5.
//

extension MZRItem {
    
    func selectionPath(withOutlineWidth width: CGFloat) -> CGPath? {
        guard let path = path() else { return nil }
        switch size {
        case .inf(continuous: let continuous, cuttable: _) where continuous:
            let boundingBox = path.boundingBox.insetBy(dx: -10, dy: -10)
            return CGPath(rect: boundingBox, transform: nil)
        default:
            return path.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 10)
        }
    }
    
}

class MZRViewModel {
    
    var state = State.select(selectionMode: .normal)
    
    private var selectionRect = CGRect.null
    
    private var lastLocation: CGPoint?
    
    private var rotator: MZRRotator?
    
    var fieldSize = CGSize.zero {
        didSet {
            let ms = CGSize(width: fieldSize.width / oldValue.width,
                            height: fieldSize.height / oldValue.height)
            zoom(ms)
        }
    }
    
    private func zoom(_ zoomScales: CGSize) {
        let t = CGAffineTransform.identity.scaledBy(x: zoomScales.width, y: zoomScales.height)
        for item in items {
            for (c, section) in item.points.enumerated() {
                for (r, point) in section.enumerated() {
                    item.points[c][r] = point.applying(t)
                }
            }
        }
        if let rotator = rotator {
            rotator.modifyPoint(rotator.points[0][0].applying(t), at: (0, 0))
        }
    }
    
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
            }
        }
    }
    
    var selectedItems = [MZRItem]() {
        didSet {
            updateRotator()
            
            let new = Set(selectedItems), old = Set(oldValue)
            let addeds = new.subtracting(old)
            let removeds = old.subtracting(new)
            
            if !addeds.isEmpty {
                itemsSelected?(Array(addeds))
            }
            
            if !removeds.isEmpty {
                itemsDeselected?(Array(removeds))
            }
        }
    }
    
    // MARK: - Settings
    
    var scale = MZRScale()
    
    var rotatorEnabled = true {
        didSet {
            updateRotator()
            shouldUpdate?()
        }
    }
    
    var drawingColor = MZRColor(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            if case .drawing(let item, _) = state {
                item.color = drawingColor
            }
            selectedItems.forEach { $0.color = drawingColor }
            shouldUpdate?()
        }
    }
    
    var scaleColor = MZRColor.green {
        didSet {
            scale.scaleColor = scaleColor
            shouldUpdate?()
        }
    }
    
    var outlineWidth = CGFloat(10)
    
    var pointOutline = CGFloat(10)
    
    var oulineColor = MZRColor.cyan
    
    var selectionBorderColor = MZRColor.white
    
    var selectionBackgroundColor = MZRColor(red: 0.3, green: 0.5, blue: 0.5, alpha: 0.5)
    
    // MARK: - Event
    
    var shouldUpdate: (() -> Void)?
    
    var finishingItem: ((MZRItem) -> Void)?
    
    var itemFinished: ((MZRItem) -> Void)?
    
    var itemModified: ((MZRItem) -> Void)?
    
    var itemsSelected: (([MZRItem]) -> Void)?
    
    var itemsDeselected: (([MZRItem]) -> Void)?
    
    var requestForDescription: ((MZRItem) -> NSAttributedString?)?
    
    // MARK: - Getters
    
    /// Selected items > unselected items.
    private func sortedItems() -> [MZRItem] {
        let selecteds = selectedItems.reversed()
        let others = Set(items).subtracting(selecteds)
        return others.sorted { self.items.firstIndex(of: $0)! < self.items.firstIndex(of: $1)! } + selecteds
    }
    
    func item(at location: CGPoint) -> MZRItem? {
        let items = sortedItems()
        let selectionPaths = items.compactMap({ $0.selectionPath(withOutlineWidth: outlineWidth) })
        guard let index = selectionPaths.firstIndex(where: { $0.contains(location) }) else { return nil }
        return items[index]
    }
    
    /// Returns item and position of a non `inf` size selected item or nil if nothing is selected.
    func positionForItem(at location: CGPoint) -> (MZRItem, MZRItem.Position)? {
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
    
    // MARK: - Life Cycle
    
    init() {
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
        let item = type.init()
        item.color = drawingColor
        state = .drawing(item: item, pressed: false)
    }
    
    /// Become selection mode.
    func normal() {
        if case .drawing(let item, _) = state {
            if item.isCompleted, item.points.flatMap({ $0 }).count > 1 {
                items.append(item)
                itemFinished?(item)
            }
        }

        selectedItems = []
        state = .select(selectionMode: .normal)
        shouldUpdate?()
    }
    
    /// Rotate single selection,
    func rotate(_ rotation: CGFloat) {
        guard let item = selectedItems.first, selectedItems.count == 1 else { return }
        item.rotation = rotation
        shouldUpdate?()
    }
    
    // MARK: - Mouse / Touch Events
    
    func began(_ location: CGPoint) {
        switch state {
        case .drawing(item: let item, pressed: _):
            switch item.size {
            case .std(_, let row) where item.points.isEmpty || item.points.last?.count == row:
                item.addPoint(location)
                
            case .inf(continuous: let continuous, cuttable: _) where !continuous && item.points.isEmpty:
                item.addPoint(location)
                
            default: break
            }
            
            item.addPoint(location)
            state = .drawing(item: item, pressed: true)
            
        case .select:
            if let (item, position) = positionForItem(at: location) {
                state = .select(selectionMode: .onPoint(item: item, position: position))
            } else if let item = item(at: location) {
                if !selectedItems.contains(item) {
                    selectedItems = [item]
                }
                state = .select(selectionMode: .onItem(item: item))
            } else {
                selectedItems = []
                selectionRect.origin = CGPoint(x: round(location.x) + 0.5, y: round(location.y) + 0.5)
            }
        }
        
        lastLocation = location
        shouldUpdate?()
    }
    
    func moved(_ location: CGPoint) {
        switch state {
        case .drawing(item: let item, pressed: _):
            let col = item.points.count - 1
            let row = item.points.last!.count - 1
            
            switch item.size {
            case .std:
                item.modifyPoint(location, at: (col, row))
                if item.isCompleted {
                    finishingItem?(item)
                }
                
            case .inf(continuous: let continuous, cuttable: _):
                continuous ? item.addPoint(location) : item.modifyPoint(location, at: (col, row))
                if !continuous && item.isCompleted {
                    finishingItem?(item)
                }
            }
            
        case .select(selectionMode: let selectionMode):
            switch selectionMode {
            case .onItem:
                state = .select(selectionMode: .draggingItems)
                moved(location)
                return
                
            case .onPoint(item: let item, position: let position):
                state = .select(selectionMode: .draggingPoint(item: item, position: position))
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
        switch state {
        case .drawing(item: let item, pressed: _):
            switch item.size {
            case .std where item.isCompleted:
                items.append(item)
                state = .select(selectionMode: .normal)
                itemFinished?(item)
                
            case .inf(continuous: _, let cuttable) where cuttable:
                item.cut()
                fallthrough
            default:
                state = .drawing(item: item, pressed: false)
            }
            
        case .select(selectionMode: let selectionMode):
            if case .onItem(let item) = selectionMode {
                selectedItems = [item]
            }
            selectionRect = .null
            state = .select(selectionMode: .normal)
        }
        
        lastLocation = nil
        shouldUpdate?()
    }
    
    // MARK: - Drawing
    
    private func drawAuxiliaryLine(_ item: MZRItem, at position: MZRItem.Position, in ctx: CGContext) {
        if case .inf(let continuous, _) = item.size, continuous { return }
        let p1 = item.points[position.0][position.1]
        let p2 = position.1 > 0 ? item.points[position.0][position.1 - 1] :
            (item.points[position.0].count > 1 ? item.points[position.0][position.1 + 1] : nil)
        
        if let p2 = p2 {
            let line = Line(from: p1, to: p2)
            let paralles = line.paralles(line.distance / 2)
            ctx.saveGState()
            ctx.addLine(paralles.0)
            ctx.addLine(paralles.1)
            ctx.setStrokeColor(item.color.cgColor)
            ctx.strokePath()
            ctx.restoreGState()
        }
    }
    
    private func drawAdditionalOutline(_ targetItem: MZRItem, in ctx: CGContext) {
        switch state {
        case .drawing(item: let item, pressed: let pressed) where item == targetItem && !(item is MZRRect):
            item.drawArch()
            if let row = item.points.last?.count.advanced(by: -1), pressed {
                let col = item.points.count - 1
                drawAuxiliaryLine(item, at: (col, row), in: ctx)
            }
            
        case .select(let selectionMode) where selectedItems.contains(targetItem):
            switch selectionMode {
            case .draggingItems:
                break
                
            case .draggingPoint(let item, let position) where item == targetItem:
                if !(item is MZRRect) {
                    item.drawArch()
                    drawAuxiliaryLine(item, at: position, in: ctx)
                }
                
            case .onPoint(item: let item, position: let pos) where item == targetItem:
                item.drawPoints(marked: [pos])
                
            default:
                switch targetItem.size {
                case .inf(continuous: let continuous, cuttable: _) where continuous:
                    guard let path = targetItem.selectionPath(withOutlineWidth: outlineWidth) else { break }
                    ctx.saveGState()
                    ctx.setLineDash(phase: 0, lengths: [4, 4])
                    ctx.addPath(path)
                    ctx.strokePath()
                    ctx.restoreGState()
                    
                default:
                    targetItem.drawPoints()
                }
            }
            
        default:
            break
        }
    }
    
    func drawDescription(_ desc: NSAttributedString, for item: MZRItem, in frame: CGRect) {
        guard let ctx = CGContext.current else { return }
        guard let boundingBox = item.path()?.boundingBox else { return }
        
        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }
        
        // Border rect
        let borderSize = CGSize(width: desc.size().width + 8, height: desc.size().height + 8)
        var borderFrame = CGRect(x: boundingBox.maxX + 4, y: boundingBox.maxY + 4, width: borderSize.width, height: borderSize.height)
        
        if borderFrame.maxX + 4 > frame.maxX {
            let offset = borderFrame.maxX + 4 - frame.maxX
            borderFrame.origin.x -= offset
        } else if borderFrame.minX - 4 < frame.minX {
            let offset = frame.minX - (borderFrame.minX - 4)
            borderFrame.origin.x += offset
        }
        
        if borderFrame.maxY + 4 > frame.maxY {
            let offset = borderFrame.maxY + 4 - frame.maxY
            borderFrame.origin.y -= offset
        } else if borderFrame.minY - 4 < frame.minY {
            let offset = frame.minY - (borderFrame.minY - 4)
            borderFrame.origin.y += offset
        }
        
        let borderPath = CGPath(roundedRect: borderFrame, cornerWidth: 5, cornerHeight: 5, transform: nil)
        
        if selectedItems.contains(item) {
            let cgColor = MZRColor(red: 0, green: 1, blue: 1, alpha: 0.5).cgColor
            ctx.addPath(borderPath)
            ctx.setFillColor(cgColor)
            ctx.fillPath()
        }
        
        ctx.addPath(borderPath)
        ctx.setStrokeColor(.black)
        ctx.strokePath()
        
        let descOrigin = CGPoint(x: borderFrame.minX + 4, y: borderFrame.minY + 4)
        desc.draw(at: descOrigin)
    }
    
    func draw(_ rect: CGRect) {
        guard let ctx = CGContext.current else { return }
        
        let currentItem = { () -> [MZRItem] in
            guard case .drawing(let item, _) = state else { return [] }
            return [item]
        }()
        
        scale.draw(rect)
        
        for item in (sortedItems() + currentItem) {
            if item.isCompleted {
                item.draw()
            }
            drawAdditionalOutline(item, in: ctx)
            if item.isCompleted {
                if let desc = requestForDescription?(item) {
                    drawDescription(desc, for: item, in: rect)
                }
            }
        }
        
        rotator?.draw()
        
        if selectionRect != .null {
            ctx.addRect(selectionRect)
            ctx.setFillColor(selectionBackgroundColor.cgColor)
            ctx.fillPath()
            
            ctx.addRect(selectionRect)
            ctx.setStrokeColor(selectionBorderColor.cgColor)
            ctx.strokePath()
        }
    }
    
}
