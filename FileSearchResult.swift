//
// FileSearchResult.swift
//
// Created by Speedyfriend67 on 29.06.24
//
 
import Foundation
import Combine

class FileSearchResults: ObservableObject {
    @Published var items: [FileSystemItem] = []
}