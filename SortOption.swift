//
// SortOption.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

enum SortOption: CaseIterable {
    case name, date, modified, size, reverseName
    
    var title: String {
        switch self {
        case .name:
            return "Name"
        case .date:
            return "Creation Date"
        case .modified:
            return "Modification Date"
        case .size:
            return "Size"
        case .reverseName:
            return "Reverse Name"
        }
    }
    
    var icon: String {
        switch self {
        case .name:
            return "textformat"
        case .date:
            return "calendar"
        case .modified:
            return "clock"
        case .size:
            return "arrow.up.arrow.down.square"
        case .reverseName:
            return "textformat.size"
        }
    }
}