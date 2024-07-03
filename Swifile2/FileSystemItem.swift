//
// FileSystemItem.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

struct FileSystemItem: Identifiable {
    var id = UUID()
    var name: String
    var isDirectory: Bool
    var url: URL
    var size: Int
    var creationDate: Date
    var modificationDate: Date
    var isSymlink: Bool
    
    // File type checks
    var isTextFile: Bool {
        return url.pathExtension.lowercased() == "txt"
    }
    
    var isImageFile: Bool {
        return ["png", "jpg", "jpeg", "gif"].contains(url.pathExtension.lowercased())
    }
    
    var isPlistFile: Bool {
        return url.pathExtension.lowercased() == "plist"
    }
    
    var isHexFile: Bool {
        return url.pathExtension.lowercased() == "dylib"
    }
}