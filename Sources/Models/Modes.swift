//
//  Modes.swift
//  MZRKit
//
//  Created by 陳世爵 on 2019/6/12.
//

import Foundation

public enum State {
    case drawing(item: MZRItem, pressed :Bool)
    case select(selectionMode: SelectionMode)
}

public enum SelectionMode {
    case normal
    case onItem(item: MZRItem)
    case onPoint(item: MZRItem, position: MZRItem.Position)
    case draggingItems
    case draggingPoint(item: MZRItem, position: MZRItem.Position)
}
