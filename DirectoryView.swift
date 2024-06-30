//
// DirectoryView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
// Ensure you have the necessary imports
import SwiftUI

struct DirectoryView: View {
    @StateObject private var viewModel: FileManagerViewModel
    @State private var showingActionSheet = false
    @State private var showingAddItemSheet = false
    @State private var showingRenameCopySheet = false
    @State private var isAddingDirectory = false
    @State private var isRenaming = false
    @State private var statusMessage = ""
    @State private var showingStatusAlert = false
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: FileSystemItem?
    @State private var itemToRenameOrCopy: FileSystemItem?
    @State private var newName: String = ""
    @State private var showingSortOptions = false
    @State private var showingSearchBar = false
    @State private var isEditing = false
    @State private var isSearchActive = false

    init(directory: URL) {
        _viewModel = StateObject(wrappedValue: FileManagerViewModel(directory: directory))
    }

    var body: some View {
        VStack {
            if showingSearchBar {
                Picker("Search Scope", selection: $viewModel.searchScope) {
                    Text(SearchScope.current.title).tag(SearchScope.current)
                    Text(SearchScope.root.title).tag(SearchScope.root)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing, .top])
            }

            if showingSearchBar {
                SearchBar(text: $viewModel.searchQuery, onSearchButtonClicked: {
                    if viewModel.searchScope == .root {
                        isSearchActive = true
                        viewModel.performSearch()
                    }
                })
                .padding([.leading, .trailing])
            }

            if viewModel.isSearching {
                ProgressView("Searching...")
                    .padding()
            } else {
                List(selection: $viewModel.selectedItems) {
                    ForEach(viewModel.filteredItems) { item in
                        NavigationLink(destination: destinationView(for: item)) {
                            HStack {
                                if isEditing {
                                    Image(systemName: viewModel.selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                        .onTapGesture {
                                            if viewModel.selectedItems.contains(item.id) {
                                                viewModel.selectedItems.remove(item.id)
                                            } else {
                                                viewModel.selectedItems.insert(item.id)
                                            }
                                        }
                                }
                                Image(systemName: item.isDirectory ? "folder" : (item.isSymlink ? "link" : "doc"))
                                Text(item.name)
                                Spacer()
                                if !item.isDirectory {
                                    Text(viewModel.formattedFileSize(item.size))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                itemToDelete = item
                                showingDeleteAlert = true
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                            Button(action: {
                                itemToRenameOrCopy = item
                                isRenaming = true
                                newName = item.name
                                showingRenameCopySheet = true
                            }) {
                                Text("Rename")
                                Image(systemName: "pencil")
                            }
                            Button(action: {
                                itemToRenameOrCopy = item
                                isRenaming = false
                                newName = item.name + " copy"
                                showingRenameCopySheet = true
                            }) {
                                Text("Copy")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.directory.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button(action: {
            withAnimation {
                isEditing.toggle()
                viewModel.selectedItems.removeAll()
            }
        }) {
            Text(isEditing ? "Done" : "Edit")
        }, trailing: HStack {
            Button(action: {
                showingActionSheet = true
            }) {
                Image(systemName: "plus")
            }
            Button(action: {
                withAnimation {
                    showingSearchBar.toggle()
                    if showingSearchBar && viewModel.searchScope == .root {
                        isSearchActive = false
                        viewModel.clearRootItems()
                    }
                }
            }) {
                Image(systemName: "magnifyingglass")
            }
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        viewModel.sortOption = option
                    }) {
                        Label(option.title, systemImage: option.icon)
                    }
                }
            } label: {
                HStack {
                    Text("Sort")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        })
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Add New Item"), message: Text("What would you like to add?"), buttons: [
                .default(Text("Folder")) {
                    isAddingDirectory = true
                    showingAddItemSheet = true
                },
                .default(Text("File")) {
                    isAddingDirectory = false
                    showingAddItemSheet = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showingAddItemSheet) {
    AddItemView(
        isPresented: $showingAddItemSheet,
        isDirectory: isAddingDirectory,
        existingNames: viewModel.items.map { $0.name }
    ) { name in
        if isAddingDirectory {
            viewModel.createFolder(named: name)
            statusMessage = "Created folder: \(name)"
        } else {
            viewModel.createFile(named: name)
            statusMessage = "Created file: \(name)"
        }
        showingStatusAlert = true
    }
}
        .sheet(isPresented: $showingRenameCopySheet) {
            RenameCopyView(
                newName: $newName,
                isPresented: $showingRenameCopySheet,
                isRename: isRenaming
            ) { newName in
                if let item = itemToRenameOrCopy {
                    if isRenaming {
                        viewModel.renameFile(at: item.url, to: newName)
                        statusMessage = "Renamed \(item.isDirectory ? "folder" : "file") to: \(newName)"
                    } else {
                        viewModel.copyFile(at: item.url, to: newName)
                        statusMessage = "Copied \(item.isDirectory ? "folder" : "file") to: \(newName)"
                    }
                    showingStatusAlert = true
                }
            }
        }
        .alert(isPresented: $showingStatusAlert) {
            Alert(
                title: Text("Status"),
                message: Text(statusMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete \(itemToDelete?.name ?? "this item")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let item = itemToDelete {
                        viewModel.deleteFile(at: item.url)
                        statusMessage = "Deleted \(item.isDirectory ? "folder" : "file"): \(item.name)"
                        showingStatusAlert = true
                    } else {
                        viewModel.deleteSelectedFiles()
                    }
                    showingDeleteAlert = false
                },
                secondaryButton: .cancel()
            )
        }

        if isEditing && !viewModel.selectedItems.isEmpty {
            Button(action: {
                showingDeleteAlert = true
            }) {
                Text("Delete Selected")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
            }
        }
    }

    @ViewBuilder
    private func destinationView(for item: FileSystemItem) -> some View {
        if item.isSymlink {
            if let resolvedURL = resolveSymlink(at: item.url) {
                DirectoryView(directory: resolvedURL)
            } else {
                Text("Invalid symlink: \(item.name)")
            }
        } else if item.isDirectory {
            DirectoryView(directory: item.url)
        } else if item.name.hasSuffix(".txt") || item.name.hasSuffix(".zshrc") {
            TextFileView(fileURL: item.url)
        } else if item.name.hasSuffix(".png") || item.name.hasSuffix(".jpg") || item.name.hasSuffix(".jpeg") || item.name.hasSuffix(".car") || item.name.hasSuffix(".heic") {
            ImageFileView(fileURL: item.url)
        } else if item.name.hasSuffix(".plist") || item.name.hasSuffix(".xml") ||
                    item.name.hasSuffix(".entitlements") {
            PlistEditorView(fileURL: item.url)
        } else if item.name.hasSuffix(".bin") || item.name.hasSuffix(".dylib") || item.name.hasSuffix(".geode") {
            HexEditorView(fileURL: item.url)
        } else if item.name.hasSuffix(".ipa") || item.name.hasSuffix(".deb") ||
                    item.name.hasSuffix(".jp2") ||
                    item.name.hasSuffix(".xz") ||
                    item.name.hasSuffix(".zip") {
            FileDetailView(fileURL: item.url)
        } else {
            Text("File: \(item.name)")
        }
    }

    private func resolveSymlink(at url: URL) -> URL? {
        do {
            let destination = try FileManager.default.destinationOfSymbolicLink(atPath: url.path)
            return URL(fileURLWithPath: destination)
       } catch {
print("Failed to resolve symlink: (error.localizedDescription)")
return nil
}
}
}