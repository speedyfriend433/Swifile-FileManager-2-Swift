//
// Extensions.swift
//
// Created by Speedyfriend67 on 30.06.24
//
 
import Foundation

enum FileOperationError: Error {
    case relativePathNotAllowed(path: String)
    case notADirectory(path: String)
    case alreadyExists(path: String)
    case unknownError(description: String)
    case notEnoughArguments
    case unknownAction
}

class FileOperations {
    
    static func contentsOfDirectory(at path: String) throws {
        if path.hasPrefix(".") {
            throw FileOperationError.relativePathNotAllowed(path: path)
        }
        
        let fm = FileManager.default
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue {
            let contents = try fm.contentsOfDirectory(atPath: path)
            for item in contents {
                print(item)
            }
        } else {
            throw FileOperationError.notADirectory(path: path)
        }
    }
    
    static func removeItem(at path: String) throws {
        let fm = FileManager.default
        try fm.removeItem(atPath: path)
    }
    
    static func createItem(at path: String) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            throw FileOperationError.alreadyExists(path: path)
        }
        let created = fm.createFile(atPath: path, contents: Data(), attributes: nil)
        if !created {
            throw FileOperationError.unknownError(description: "Failed to create file at path: \(path)")
        }
        do {
            try fm.setAttributes([FileAttributeKey.ownerAccountID: 501, FileAttributeKey.groupOwnerAccountID: 501], ofItemAtPath: path)
        } catch {
            throw FileOperationError.unknownError(description: "Failed to set owner. \(error.localizedDescription)")
        }
    }
    
    static func copyFile(from: String, to: String) throws {
        let fm = FileManager.default
        try fm.copyItem(atPath: from, toPath: to)
    }
    
    static func moveItem(from: String, to: String) throws {
        try copyFile(from: from, to: to)
        try removeItem(at: from)
    }
}
