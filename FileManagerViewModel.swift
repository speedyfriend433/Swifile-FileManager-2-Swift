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
    @Published var rootItems: [FileSystemItem] = []
    @Published var selectedItems: Set<UUID> = []
    @Published var sortOption: SortOption = .name {
        didSet {
            sortItems()
        }
    }
    @Published var searchQuery: String = "" {
        didSet {
            filterItems()
        }
    }
    @Published var searchScope: SearchScope = .current {
        didSet {
            if searchScope == .root {
                loadRootFiles()
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

    func loadFiles() {
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey], options: [.skipsHiddenFiles])
            DispatchQueue.main.async {
                self.items = directoryContents.map { url in
                    let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey])
                    let isDirectory = resourceValues?.isDirectory ?? false
                    let fileSize = resourceValues?.fileSize ?? 0
                    let creationDate = resourceValues?.creationDate ?? Date()
                    let modificationDate = resourceValues?.contentModificationDate ?? Date()
                    return FileSystemItem(name: url.lastPathComponent, isDirectory: isDirectory, path: url, size: fileSize, creationDate: creationDate, modificationDate: modificationDate)
                }
                self.sortItems()
                self.filterItems()
            }
        } catch {
            print("Failed to load files: \(error.localizedDescription)")
        }
    }

    func loadRootFiles() {
        isSearching = true
        rootSearchCancellable?.cancel()
        rootSearchCancellable = Future<[FileSystemItem], Error> { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                let rootURL = URL(fileURLWithPath: "/")
                let rootItems = self.recursiveFileSearch(at: rootURL)
                promise(.success(rootItems))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                print("Failed to search root files: \(error.localizedDescription)")
                self.isSearching = false
            }
        } receiveValue: { rootItems in
            self.rootItems = rootItems
            self.isSearching = false
            self.filterItems()
        }
    }

    private func cancelRootSearch() {
        rootSearchCancellable?.cancel()
        isSearching = false
    }

    private func recursiveFileSearch(at url: URL) -> [FileSystemItem] {
        var result: [FileSystemItem] = []
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey], options: [.skipsHiddenFiles])
            for item in contents {
                let resourceValues = try? item.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey])
                let isDirectory = resourceValues?.isDirectory ?? false
                let fileSize = resourceValues?.fileSize ?? 0
                let creationDate = resourceValues?.creationDate ?? Date()
                let modificationDate = resourceValues?.contentModificationDate ?? Date()
                let fileSystemItem = FileSystemItem(name: item.lastPathComponent, isDirectory: isDirectory, path: item, size: fileSize, creationDate: creationDate, modificationDate: modificationDate)
                if fileSystemItem.name.lowercased().contains(searchQuery.lowercased()) {
                    result.append(fileSystemItem)
                }
                if isDirectory {
                    result.append(contentsOf: recursiveFileSearch(at: item))
                }
            }
        } catch {
            print("Failed to search files: \(error.localizedDescription)")
        }
        return result
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
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
        }
    }

    func deleteSelectedFiles() {
        for id in selectedItems {
            if let item = items.first(where: { $0.id == id }) {
                deleteFile(at: item.path)
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
            loadFiles()
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
            print("Failed to copy file: \(error.localizedDescription)")
        }
    }

    func formattedFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}