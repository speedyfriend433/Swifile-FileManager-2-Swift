//
// Extensions.swift
//
// Created by Speedyfriend67 on 30.06.24
//
 
import Foundation

enum FileOperationError: Error {
    case notADirectory(path: String)
    case alreadyExists(path: String)
    case relativePathNotAllowed(path: String)
    case unknownError(description: String)
}

class FileOperations {
    
    static func contentsOfDirectory(at path: String) throws {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        
        guard !path.hasPrefix(".") else {
            throw FileOperationError.relativePathNotAllowed(path: path)
        }
        
        guard fileManager.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue else {
            throw FileOperationError.notADirectory(path: path)
        }
        
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        for item in contents {
            if item != "." && item != ".." {
                print(item)
            }
        }
    }
    
    static func removeItem(at path: String) throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: path)
    }
    
    static func createItem(at path: String) throws {
        let fileManager = FileManager.default
        
        guard !fileManager.fileExists(atPath: path) else {
            throw FileOperationError.alreadyExists(path: path)
        }
        
        fileManager.createFile(atPath: path, contents: Data(), attributes: nil)
        do {
            let attributes: [FileAttributeKey: Any] = [
                .ownerAccountID: 501, // Equivalent to 'mobile' user in some environments
                .groupOwnerAccountID: 501
            ]
            try fileManager.setAttributes(attributes, ofItemAtPath: path)
        } catch {
            throw FileOperationError.unknownError(description: "Failed to set owner. \(error.localizedDescription)")
        }
    }
    
    static func copyFile(from fromPath: String, to toPath: String) throws {
        let fileManager = FileManager.default
        try fileManager.copyItem(atPath: fromPath, toPath: toPath)
    }
    
    static func moveItem(from fromPath: String, to toPath: String) throws {
        let fileManager = FileManager.default
        try fileManager.moveItem(atPath: fromPath, toPath: toPath)
    }
}
