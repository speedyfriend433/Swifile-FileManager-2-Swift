import Foundation
import Combine
import UIKit
import MobileCoreServices

enum FilePermission: String, CaseIterable {
    case userRead = "User Read"
    case userWrite = "User Write"
    case userExecute = "User Execute"
    case groupRead = "Group Read"
    case groupWrite = "Group Write"
    case groupExecute = "Group Execute"
    case othersRead = "Others Read"
    case othersWrite = "Others Write"
    case othersExecute = "Others Execute"
}

struct FileMetadata {
    let name: String
    let size: String
    let creationDate: String
    let modificationDate: String
}

class FileManagerViewModel: ObservableObject {
    @Published var items: [FileSystemItem] = []
    @Published var filteredItems: [FileSystemItem] = []
    @Published var rootItems: [FileSystemItem] = []
    @Published var selectedItems: Set<UUID> = []
    @Published var selectedFile: FileSystemItem?
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
            if searchScope == .root && !searchQuery.isEmpty {
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

    func formattedFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }

    func loadFiles() {
        isSearching = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let directoryContents = try self.fileManager.contentsOfDirectory(at: self.directory, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey], options: [])
                for url in directoryContents {
                    let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey])
                    let isDirectory = resourceValues?.isDirectory ?? false
                    let isSymlink = resourceValues?.isSymbolicLink ?? false
                    let fileSize = resourceValues?.fileSize ?? 0
                    let creationDate = resourceValues?.creationDate ?? Date()
                    let modificationDate = resourceValues?.contentModificationDate ?? Date()
                    let appIcon = self.getAppIcon(for: url)
                    let appName = self.getAppName(for: url)
                    let fileSystemItem = FileSystemItem(name: url.lastPathComponent, isDirectory: isDirectory, url: url, size: fileSize, creationDate: creationDate, modificationDate: modificationDate, isSymlink: isSymlink, appIcon: appIcon, appName: appName)
                    DispatchQueue.main.async {
                        self.items.append(fileSystemItem)
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

    private func getAppIcon(for url: URL) -> UIImage? {
        guard let workspace = NSClassFromString("LSApplicationWorkspace") as? NSObject.Type,
              let workspaceInstance = workspace.perform(NSSelectorFromString("defaultWorkspace")).takeUnretainedValue() as? NSObject,
              let apps = workspaceInstance.perform(NSSelectorFromString("allInstalledApplications")).takeUnretainedValue() as? [NSObject] else {
            return nil
        }

        for app in apps {
            if let appPath = app.perform(NSSelectorFromString("bundleURL")).takeUnretainedValue() as? URL, appPath == url {
                if let icons = app.perform(NSSelectorFromString("icon")).takeUnretainedValue() as? [String: Any],
                   let iconFiles = icons["CFBundleIconFiles"] as? [String],
                   let iconFile = iconFiles.last,
                   let iconImage = UIImage(named: iconFile) {
                    return iconImage
                }
            }
        }
        return nil
    }

    private func getAppName(for url: URL) -> String? {
        guard let workspace = NSClassFromString("LSApplicationWorkspace") as? NSObject.Type,
              let workspaceInstance = workspace.perform(NSSelectorFromString("defaultWorkspace")).takeUnretainedValue() as? NSObject,
              let apps = workspaceInstance.perform(NSSelectorFromString("allInstalledApplications")).takeUnretainedValue() as? [NSObject] else {
            return nil
        }

        for app in apps {
            if let appPath = app.perform(NSSelectorFromString("bundleURL")).takeUnretainedValue() as? URL, appPath == url {
                return app.perform(NSSelectorFromString("localizedName")).takeUnretainedValue() as? String
            }
        }
        return nil
    }

    func showFilePermissions(for item: FileSystemItem) {
        selectedFile = item
    }

    func getFileSize(at url: URL) -> String {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? NSNumber {
                return ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
            }
        } catch {
            print("Failed to get file size: \(error.localizedDescription)")
        }
        return "Unknown"
    }

    func getCreationDate(at url: URL) -> String {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let date = attributes[.creationDate] as? Date {
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
            }
        } catch {
            print("Failed to get creation date: \(error.localizedDescription)")
        }
        return "Unknown"
    }

    func getModificationDate(at url: URL) -> String {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let date = attributes[.modificationDate] as? Date {
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
            }
        } catch {
            print("Failed to get modification date: \(error.localizedDescription)")
        }
        return "Unknown"
    }

    func getFileMetadata(at url: URL) -> FileMetadata {
        let name = url.lastPathComponent
        let size = getFileSize(at: url)
        let creationDate = getCreationDate(at: url)
        let modificationDate = getModificationDate(at: url)
        return FileMetadata(name: name, size: size, creationDate: creationDate, modificationDate: modificationDate)
    }

    func isPermissionGranted(for url: URL, permission: FilePermission) -> Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let posixPermissions = attributes[.posixPermissions] as? NSNumber {
                let posixInt = posixPermissions.uint16Value
                switch permission {
                case .userRead:
                    return (posixInt & UInt16(S_IRUSR)) != 0
                case .userWrite:
                    return (posixInt & UInt16(S_IWUSR)) != 0
                case .userExecute:
                    return (posixInt & UInt16(S_IXUSR)) != 0
                case .groupRead:
                    return (posixInt & UInt16(S_IRGRP)) != 0
                case .groupWrite:
                    return (posixInt & UInt16(S_IWGRP)) != 0
                case .groupExecute:
                    return (posixInt & UInt16(S_IXGRP)) != 0
                case .othersRead:
                    return (posixInt & UInt16(S_IROTH)) != 0
                case .othersWrite:
                    return (posixInt & UInt16(S_IWOTH)) != 0
                case .othersExecute:
                    return (posixInt & UInt16(S_IXOTH)) != 0
                }
            }
        } catch {
            print("Failed to retrieve file attributes: \(error.localizedDescription)")
        }
        return false
    }

    func toggleFilePermission(at url: URL, permission: FilePermission) {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let posixPermissions = attributes[.posixPermissions] as? NSNumber {
                var posixInt = posixPermissions.uint16Value
                switch permission {
                case .userRead:
                    posixInt ^= UInt16(S_IRUSR)
                case .userWrite:
                    posixInt ^= UInt16(S_IWUSR)
                case .userExecute:
                    posixInt ^= UInt16(S_IXUSR)
                case .groupRead:
                    posixInt ^= UInt16(S_IRGRP)
                case .groupWrite:
                    posixInt ^= UInt16(S_IWGRP)
                case .groupExecute:
                    posixInt ^= UInt16(S_IXGRP)
                case .othersRead:
                    posixInt ^= UInt16(S_IROTH)
                case .othersWrite:
                    posixInt ^= UInt16(S_IWOTH)
                case .othersExecute:
                    posixInt ^= UInt16(S_IXOTH)
                }
                let newPermissions = NSNumber(value: posixInt)
                try FileManager.default.setAttributes([.posixPermissions: newPermissions], ofItemAtPath: url.path)
            }
        } catch {
            print("Failed to toggle file permission: \(error.localizedDescription)")
        }
    }

    func loadRootFiles() {
        isSearching = true
        rootSearchCancellable?.cancel()
        let searchResults = FileSearchResults()
        rootSearchCancellable = searchResults.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.rootItems = items
                self?.isSearching = false
                self?.filterItems()
            }

        self.results.removeAll()
        startRefreshTimer(searchResults: searchResults)
        startRecursion()
    }
    
    private var refreshTimer: Timer?
    private var workItem: DispatchWorkItem?
    private var results = [FileSystemItem]()

    func startRecursion() {
        workItem?.cancel()
        workItem = DispatchWorkItem {
            if self.workItem?.isCancelled == true { return }
            self.recursiveFileSearch(at: URL(fileURLWithPath: "/"), workItem: self.workItem!)
        }
        DispatchQueue.global().async(execute: workItem!)
    }

    func startRefreshTimer(searchResults: FileSearchResults) {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let elementsToTransfer = min(1000, self.results.count)
            let batch = self.results.prefix(elementsToTransfer)
            searchResults.items.append(contentsOf: batch)
            self.results.removeFirst(elementsToTransfer)
        }
    }
    
    private func recursiveFileSearch(at url: URL, workItem: DispatchWorkItem) {
        var tempResults = [FileSystemItem]()
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey], options: [])
            for (_, item) in contents.enumerated() {
                if workItem.isCancelled == true { return } 
                
                let resourceValues = try? item.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isSymbolicLinkKey])
                let isDirectory = resourceValues?.isDirectory ?? false
                let isSymlink = resourceValues?.isSymbolicLink ?? false
                let fileSize = resourceValues?.fileSize ?? 0
                let creationDate = resourceValues?.creationDate ?? Date()
                let modificationDate = resourceValues?.contentModificationDate ?? Date()
                let fileSystemItem = FileSystemItem(name: item.lastPathComponent, isDirectory: isDirectory, url: item, size: fileSize, creationDate: creationDate, modificationDate: modificationDate, isSymlink: isSymlink)
                
                tempResults.append(fileSystemItem)
                
                if isDirectory {
                    recursiveFileSearch(at: item, workItem: workItem)
                }
            }
            
            DispatchQueue.main.async {
                self.results.append(contentsOf: tempResults)
            }
        } catch {
            print("Failed to search files: (error.localizedDescription)")
        }
    }

    private func cancelRootSearch() {
        rootSearchCancellable?.cancel()
        isSearching = false
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
        case .size:
            items.sort { $0.size > $1.size }
            rootItems.sort { $0.size > $1.size }
        case .reverseName:
            items.sort { $0.name.lowercased() > $1.name.lowercased() }
            rootItems.sort { $0.name.lowercased() > $1.name.lowercased() }
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
            filteredItems = searchScope == .current ? sourceItems : []
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
}
