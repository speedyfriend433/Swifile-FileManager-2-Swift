//
// FileSystemItem.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import Foundation
import UIKit

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
        let textFileExtensions = ["txt", "xml", "entitlements", "swift", "js", "json"]
        return textFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isPlistFile: Bool {
        let plistFileExtensions = ["plist", "strings", "loctable"]
        return plistFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isHexFile: Bool {
        let hexFileExtensions = ["hex", "dylib"]
        return hexFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isImageFile: Bool {
        let imageFileExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "car"]
        return imageFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isVideoFile: Bool {
        let videoFileExtensions = ["mp4", "mov"]
        return videoFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isAudioFile: Bool {
        let audioFileExtensions = ["mp3", "wav", "m4a"]
        return audioFileExtensions.contains(url.pathExtension.lowercased())
    }
}
