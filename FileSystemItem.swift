//
// FileSystemItem.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation

struct FileSystemItem: Identifiable {
    let id = UUID()
    let name: String
    let isDirectory: Bool
    let path: URL
    let size: Int
    let creationDate: Date
    let modificationDate: Date
}