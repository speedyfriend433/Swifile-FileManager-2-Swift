//
// FileManagerViewModel.swift
//
// Created by Speedyfriend67 on 27.06.24
//

import Foundation
import Combine

class FileManagerViewModel: ObservableObject {
    @Published var items: [FileSystemItem] = []
    @Published var filteredItems: [FileSystemItem] = []
    @Published var progress: Double = 0.0
    @Published var rootItems: [FileSystemItem] = []
    @Published var selectedItems: Set<UUID> = []
    @Published var sortOption: SortOption = .name {
        didSet {
            sortItems()
        }
    }
    @Published var searchQuery: String = "" {
        didSet {
            if searchScope == .current {
                filterItems()
            }
        }
    }
    @Published var searchScope: SearchScope = .current {
        didSet {
            if searchScope == .root {
                clearRootItems()
            } else {
                cancelRootSearch()
                filterItems()
            }
        }
    }
    @Published var isSearching: Bool = false
    var directory: URL
    private let fileManager = FileManager.default
    private var rootSearchCancellable: AnyCancellable?

    init(directory: URL = URL(fileURLWithPath: "/var")) {
        self.directory = directory
        loadFiles()
    }

    func formattedFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
    
    func addFile(at url: URL) {
        let destinationURL = directory.appendingPathComponent(url.lastPathComponent)
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            loadFiles()
        } catch {
            print("Failed to add file: \(error.localizedDescription)")
        }
    }

    func loadFiles() {
        isSearching = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let directoryContents = try self.fileManager.contentsOfDirectory(at: self.directory, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey], options: [])
                let totalContents = directoryContents.count
                for (index, url) in directoryContents.enumerated() {
                    let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey])
                    let isDirectory = resourceValues?.isDirectory ?? false
                    let isSymlink = resourceValues?.isSymbolicLink ?? false
                    let fileSize = resourceValues?.fileSize ?? 0
                    let creationDate = resourceValues?.creationDate ?? Date()
                    let modificationDate = resourceValues?.contentModificationDate ?? Date()
                    let fileSystemItem = FileSystemItem(name: url.lastPathComponent, isDirectory: isDirectory, url: url, size: fileSize, creationDate: creationDate, modificationDate: modificationDate, isSymlink: isSymlink)
                    DispatchQueue.main.async {
                        self.items.append(fileSystemItem)
                        self.progress = Double(index + 1) / Double(totalContents)
                    }
                }
                DispatchQueue.main.async {
                    self.sortItems()
                    self.filterItems()
                    self.isSearching = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSearching = false
                    print("Failed to load files: \(error.localizedDescription)")
                }
            }
        }
    }

    private func recursiveFileSearch(at url: URL, result: FileSearchResults) {
    do {
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey], options: [])
        for item in contents {
            let resourceValues = try? item.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey])
            let isDirectory = resourceValues?.isDirectory ?? false
            let isSymlink = resourceValues?.isSymbolicLink ?? false
            let fileSize = resourceValues?.fileSize ?? 0
            let creationDate = resourceValues?.creationDate ?? Date()
            let modificationDate = resourceValues?.contentModificationDate ?? Date()
            let fileSystemItem = FileSystemItem(name: item.lastPathComponent, isDirectory: isDirectory, url: item, size: fileSize, creationDate: creationDate, modificationDate: modificationDate, isSymlink: isSymlink)
            if shouldIncludeItem(fileSystemItem) {
                DispatchQueue.main.async {
                    result.items.append(fileSystemItem)
                }
            }
            if isDirectory {
                recursiveFileSearch(at: item, result: result)
            }
        }
    } catch {
        print("Failed to search files: \(error.localizedDescription)")
    }
}

    private func shouldIncludeItem(_ item: FileSystemItem) -> Bool {
        if searchQuery.isEmpty {
            return true
        }
        let query = searchQuery.lowercased()
        if item.name.lowercased().contains(query) {
            return true
        }
        if let content = try? String(contentsOf: item.url).lowercased(), content.contains(query) {
            return true
        }
        return false
    }

    func performSearch() {
        guard !searchQuery.isEmpty else { return }
        isSearching = true
        rootSearchCancellable?.cancel()
        let searchResults = FileSearchResults()
        rootSearchCancellable = searchResults.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.rootItems = items.sorted { $0.url.path < $1.url.path }
                self?.isSearching = false
                self?.filterItems()
            }

        DispatchQueue.global(qos: .userInitiated).async {
            self.recursiveFileSearch(at: URL(fileURLWithPath: "/"), result: searchResults)
        }
    }

    private func cancelRootSearch() {
        rootSearchCancellable?.cancel()
        isSearching = false
    }

    func clearRootItems() {
        rootItems.removeAll()
        filteredItems.removeAll()
    }

    func sortItems() {
        switch sortOption {
        case .name:
            items.sort { $0.name.lowercased() < $1.name.lowercased() }
            rootItems.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .date:
            items.sort { $0.creationDate < $1.creationDate }
            rootItems.sort { $0.creationDate < $1.creationDate }
        case .modified:
            items.sort { $0.modificationDate < $1.modificationDate }
            rootItems.sort { $0.modificationDate < $1.modificationDate }
        }
        filterItems()
    }

    func filterItems() {
        let sourceItems: [FileSystemItem]
        switch searchScope {
        case .current:
            sourceItems = items
        case .root:
            sourceItems = rootItems
        }

        if searchQuery.isEmpty {
            filteredItems = sourceItems
        } else {
            filteredItems = sourceItems.filter { $0.name.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    func deleteFile(at url: URL) {
        do {
            try fileManager.removeItem(at: url)
            loadFiles()
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
        }
    }

    func deleteSelectedFiles() {
        for id in selectedItems {
            if let item = items.first(where: { $0.id == id }) {
                deleteFile(at: item.url)
            }
        }
        selectedItems.removeAll()
        loadFiles()
    }

    func createFile(named fileName: String) {
    let fileURL = directory.appendingPathComponent(fileName)
    let content = "This is a new file."
    do {
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        // Instead of reloading the files which might cause duplicates, just add the new file to the items array
        let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey])
        let fileSize = resourceValues?.fileSize ?? 0
        let creationDate = resourceValues?.creationDate ?? Date()
        let modificationDate = resourceValues?.contentModificationDate ?? Date()
        let newItem = FileSystemItem(name: fileURL.lastPathComponent, isDirectory: false, url: fileURL, size: fileSize, creationDate: creationDate, modificationDate: modificationDate, isSymlink: false)
        items.append(newItem)
        sortItems()
        filterItems()
    } catch {
        print("Failed to create file: \(error.localizedDescription)")
    }
}

    func createFolder(named folderName: String) {
        let folderURL = directory.appendingPathComponent(folderName)
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            loadFiles()
        } catch {
            print("Failed to create folder: \(error.localizedDescription)")
        }
    }

    func renameFile(at url: URL, to newName: String) {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        do {
            try fileManager.moveItem(at: url, to: newURL)
            loadFiles()
        } catch {
            print("Failed to rename file: \(error.localizedDescription)")
        }
    }

    func copyFile(at url: URL, to newName: String) {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        do {
            try fileManager.copyItem(at: url, to: newURL)
            loadFiles()
        } catch {
            print("Failed to copy file: \(error.localizedDescription)")    }
}
}