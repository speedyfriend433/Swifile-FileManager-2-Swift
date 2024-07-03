//
// SortOption.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

enum SortOption: String, CaseIterable {
    case name = "Name"
    case date = "Date"
    case modified = "Modified"

    var title: String {
        switch self {
        case .name: return "Name"
        case .date: return "Date"
        case .modified: return "Modified"
        }
    }

    var icon: String {
        switch self {
        case .name: return "textformat"
        case .date: return "calendar"
        case .modified: return "clock"
        }
    }
}

