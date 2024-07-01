//
// DirectoryView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
// 

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

    init(directory: URL) {
        _viewModel = StateObject(wrappedValue: FileManagerViewModel(directory: directory))
    }

    var body: some View {
        VStack {
            Picker("Search Scope", selection: $viewModel.searchScope) {
                Text(SearchScope.current.title).tag(SearchScope.current)
                Text(SearchScope.root.title).tag(SearchScope.root)
            }
            .pickerStyle(SegmentedPickerStyle())

            if showingSearchBar {
                SearchBar(text: $viewModel.searchQuery, onSearchButtonClicked: {
                    viewModel.filterItems()
                })
            }

            if viewModel.isSearching {
                ProgressView("Searching...")
            } else {
                List(selection: $viewModel.selectedItems) {
                    ForEach(viewModel.filteredItems) { item in
                        NavigationLink(destination: destinationView(for: item)) {
                            HStack {
                                if isEditing {
                                    Image(systemName: viewModel.selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                }

                                Image(systemName: item.isDirectory ? "folder" : (item.isSymlink ? "link" : "doc"))
                                Text(item.name)
                                Spacer()
                                Text(viewModel.formattedFileSize(item.size))
                            }
                            .contextMenu {
                                Button(action: {
                                    viewModel.showFilePermissions(for: item)
                                }) {
                                    Text("File Permissions")
                                    Image(systemName: "info.circle")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.directory.lastPathComponent)
        .navigationBarItems(leading: Button(action: {
            withAnimation {
                isEditing.toggle()
            }
        }) {
            Text(isEditing ? "Done" : "Edit")
        }, trailing: HStack {
            Button(action: {
                showingAddItemSheet = true
                isAddingDirectory = true
            }) {
                Image(systemName: "plus")
            }
            Button(action: {
                withAnimation {
                    showingSearchBar.toggle()
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
            AddItemView(isPresented: $showingAddItemSheet, isDirectory: isAddingDirectory, existingNames: viewModel.items.map { $0.name }) { name in
                if isAddingDirectory {
                    viewModel.createFolder(named: name)
                } else {
                    viewModel.createFile(named: name)
                }
            }
        }
        .sheet(isPresented: $showingRenameCopySheet) {
            RenameCopyView(newName: $newName, isPresented: $showingRenameCopySheet, isRename: isRenaming) { name in
                if isRenaming, let item = itemToRenameOrCopy {
                    viewModel.renameFile(at: item.url, to: name)
                } else if let item = itemToRenameOrCopy {
                    viewModel.copyFile(at: item.url, to: name)
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
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(item: $viewModel.selectedFile) { selectedFile in
            FilePermissionView(viewModel: viewModel, fileURL: selectedFile.url)
        }
        if isEditing && !viewModel.selectedItems.isEmpty {
            HStack {
                Button(action: {
                    showingActionSheet = true
                }) {
                    Text("Add")
                    Image(systemName: "plus")
                }
                Spacer()
                Button(action: {
                    showingRenameCopySheet = true
                    isRenaming = true
                    itemToRenameOrCopy = viewModel.selectedItems.first.flatMap { id in
                        viewModel.items.first { $0.id == id }
                    }
                }) {
                    Text("Rename")
                    Image(systemName: "pencil")
                }
                Spacer()
                Button(action: {
                    showingRenameCopySheet = true
                    isRenaming = false
                    itemToRenameOrCopy = viewModel.selectedItems.first.flatMap { id in
                        viewModel.items.first { $0.id == id }
                    }
                }) {
                    Text("Copy")
                    Image(systemName: "doc.on.doc")
                }
                Spacer()
                Button(action: {
                    showingDeleteAlert = true
                    itemToDelete = viewModel.selectedItems.first.flatMap { id in
                        viewModel.items.first { $0.id == id }
                    }
                }) {
                    Text("Delete")
                    Image(systemName: "trash")
                }
            }
            .padding()
            .background(Color(.systemGray6))
        }
    }

    private func destinationView(for item: FileSystemItem) -> some View {
        if item.isDirectory {
            return AnyView(DirectoryView(directory: item.url))
        } else if item.isSymlink, let resolvedURL = resolveSymlink(at: item.url) {
            return AnyView(DirectoryView(directory: resolvedURL))
        } else {
            switch item.url.pathExtension.lowercased() {
            case "txt", "md":
                return AnyView(TextFileView(fileURL: item.url))
            case "png", "jpg", "jpeg", "gif":
                return AnyView(ImageFileView(fileURL: item.url))
            case "plist":
                return AnyView(PlistEditorView(fileURL: item.url))
            case "hex":
                return AnyView(HexEditorView(fileURL: item.url))
            default:
                return AnyView(FileDetailView(fileURL: item.url))
            }
        }
    }

    private func resolveSymlink(at url: URL) -> URL? {
        do {
            let destination = try FileManager.default.destinationOfSymbolicLink(atPath: url.path)
            return URL(fileURLWithPath: destination)
        } catch {
            print("Failed to resolve symlink: \(error.localizedDescription)")
            return nil
        }
    }
}