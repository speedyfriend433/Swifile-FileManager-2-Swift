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
}