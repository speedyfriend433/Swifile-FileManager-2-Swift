//
// SearchScope.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

enum SearchScope: String, CaseIterable {
    case current = "Current"
    case root = "Root"

    var title: String {
        switch self {
        case .current: return "Current Directory"
        case .root: return "Root Directory"
        }
    }
}