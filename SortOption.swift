//
// SortOption.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

enum SortOption: String, CaseIterable {
    
    case name
    case date
    case modified
    case size

    var title: String {
        switch self {
        case .name: return "Name"
        case .date: return "Date Created"
        case .modified: return "Date Modified"
        case .size: return "Size"
        }
    }

    var icon: String {
        switch self {
        case .name: return "textformat"
        case .date: return "calendar"
        case .modified: return "clock"
        case .size: return "arrow.up.arrow.down.square"
        }
    }
}