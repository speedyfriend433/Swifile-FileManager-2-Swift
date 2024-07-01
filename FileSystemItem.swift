//
// FileSystemItem.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

import Foundation

struct FileSystemItem: Identifiable {
    let id = UUID()
    let name: String
    let isDirectory: Bool
    let url: URL
    let size: Int
    let creationDate: Date
    let modificationDate: Date
    let isSymlink: Bool
    
    var isTextFile: Bool {
        url.pathExtension.lowercased() == "txt"
    }
    
    var isImageFile: Bool {
        ["jpg", "jpeg", "png", "gif"].contains(url.pathExtension.lowercased())
    }
    
    var isPlistFile: Bool {
        url.pathExtension.lowercased() == "plist"
    }
    
    var isHexFile: Bool {
        url.pathExtension.lowercased() == "hex"
    }
}