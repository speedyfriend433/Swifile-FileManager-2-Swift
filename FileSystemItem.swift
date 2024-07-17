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
    var appIcon: UIImage?
    var appName: String?
    
    var isTextFile: Bool {
        let textFileExtensions = ["txt", "xml", "entitlements", "xm", "py", "swift", "x", "hwpx", "js", "hwp"]
        return textFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isPlistFile: Bool {
        let plistFileExtensions = ["plist", "entitlements", "strings"]
        return plistFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isHexFile: Bool {
        let hexFileExtensions = ["hex", "dylib"]
        return hexFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isImageFile: Bool {
        let imageFileExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff"]
        return imageFileExtensions.contains(url.pathExtension.lowercased())
    }

    var isVideoFile: Bool {
        let videoFileExtensions = ["mov", "mp4"]
        return videoFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var isAudioFile: Bool {
        let audioFileExtensions = ["mp3", "m4a", "wav", "flac"]
        return audioFileExtensions.contains(url.pathExtension.lowercased())
    }
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}