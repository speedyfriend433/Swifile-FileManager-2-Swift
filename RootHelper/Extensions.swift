//
// Extensions.swift
//
// Created by Speedyfriend67 on 30.06.24
//
 
import Foundation

enum FileOperationError: Error {
    case invalidPath
    case unknownError(description: String)
    case alreadyExists(path: String)
    case notADirectory(path: String)
    case relativePathNotAllowed(path: String)
}

class FileOperations {
    static func contentsOfDirectory(at path: String) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        for item in contents {
            print(item)
        }
    }

    static func removeItem(at path: String) throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: path)
    }

    static func createItem(at path: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            throw FileOperationError.alreadyExists(path: path)
        }
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
    }

    static func createDirectory(at path: String) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }

    static func copyFile(from sourcePath: String, to destinationPath: String) throws {
        let fileManager = FileManager.default
        try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
    }

    static func moveItem(from sourcePath: String, to destinationPath: String) throws {
        let fileManager = FileManager.default
        try fileManager.moveItem(atPath: sourcePath, toPath: destinationPath)
    }
}
