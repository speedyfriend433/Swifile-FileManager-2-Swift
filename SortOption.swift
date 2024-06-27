//
// SortOption.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

enum SortOption: CaseIterable {
    case name
    case date
    case modified

    var title: String {
        switch self {
        case .name:
            return "Name"
        case .date:
            return "Date"
        case .modified:
            return "Modified"
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
        }
    }
}