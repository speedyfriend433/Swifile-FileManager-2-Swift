//
// SearchScope.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

enum SearchScope {
    case current
    case root

    var title: String {
        switch self {
        case .current:
            return "Current"
        case .root:
            return "Root"
        }
    }
}