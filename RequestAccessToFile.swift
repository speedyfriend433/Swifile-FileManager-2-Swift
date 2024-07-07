//
// RequestAccessToFile.swift
//
// Created by Speedyfriend67 on 07.07.24
//
 
import Foundation

func requestAccessToFile(at url: URL) -> Bool {
    let fileCoordinator = NSFileCoordinator()
    var error: NSError?
    var isAccessible = false

    fileCoordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &error) { newURL in
        isAccessible = true
    }

    if let error = error {
        print("Failed to access file: \(error.localizedDescription)")
    }

    return isAccessible
}