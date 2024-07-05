//
// DirectoryView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
// 
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct DirectoryView: View {
    @ObservedObject private var viewModel: FileManagerViewModel
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
        _viewModel = ObservedObject(wrappedValue: FileManagerViewModel(directory: directory))
    }
    
    var body: some View {
        VStack {
            if showingSearchBar {
                Picker("Search Scope", selection: $viewModel.searchScope) {
                    Text(SearchScope.current.title).tag(SearchScope.current)
                    Text(SearchScope.root.title).tag(SearchScope.root)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            if showingSearchBar {
                SearchBar(text: $viewModel.searchQuery, onSearchButtonClicked: {
                    hideKeyboard()
                    if viewModel.searchScope == .root {
                        viewModel.loadRootFiles()
                    }
                })
                .padding(.horizontal)
            }

            if viewModel.isSearching {
                ProgressView("Searching...")
                    .padding()
            }
            
            List(selection: $viewModel.selectedItems) {
                ForEach(viewModel.filteredItems) { item in
                    NavigationLink(destination: destinationView(for: item)) {
                        HStack {
                            if isEditing {
                                Image(systemName: viewModel.selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                            }
                            if item.isDirectory {
                                Image(systemName: "folder")
                            } else if item.isSymlink {
                                Image(systemName: "link")
                            } else {
                                Image(systemName: "doc")
                            }
                            Text(item.name)
                            Spacer()
                            if !item.isDirectory {
                                Text(viewModel.formattedFileSize(item.size))
                            }
                            Button(action: {
                                viewModel.showFilePermissions(for: item)
                            }) {
                                Image(systemName: "info.circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(.leading, 10)
                        }
                        .contextMenu {
                            Button(action: {
                                itemToRenameOrCopy = item
                                isRenaming = true
                                showingRenameCopySheet = true
                            }) {
                                Text("Rename")
                                Image(systemName: "pencil")
                            }
                            Button(action: {
                                itemToRenameOrCopy = item
                                isRenaming = false
                                showingRenameCopySheet = true
                            }) {
                                Text("Copy")
                                Image(systemName: "doc.on.doc")
                            }
                            Button(action: {
                                itemToDelete = item
                                showingDeleteAlert = true
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.directory.lastPathComponent)
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
        }
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
                if let item = itemToRenameOrCopy {
                    if isRenaming {
                        viewModel.renameFile(at: item.url, to: name)
                    } else {
                        viewModel.copyFile(at: item.url, to: name)
                    }
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
    }

    private func destinationView(for item: FileSystemItem) -> some View {
    if item.isDirectory {
        if item.isSymlink {
            if let resolvedURL = resolveSymlink(at: item.url) {
                return AnyView(DirectoryView(directory: resolvedURL))
            } else {
                return AnyView(Text("Invalid symlink: \(item.name)"))
            }
        } else {
            return AnyView(DirectoryView(directory: item.url))
        }
    } else if item.isTextFile {
        return AnyView(TextFileView(fileURL: item.url))
    } else if item.isImageFile {
        return AnyView(ImageFileView(fileURL: item.url))
    } else if item.isPlistFile {
        return AnyView(PlistEditorView(fileURL: item.url))
    } else if item.isHexFile {
        return AnyView(HexEditorView(fileURL: item.url))
    } else {
        return AnyView(FileDetailView(fileURL: item.url))
    }
}

    private func resolveSymlink(at url: URL) -> URL? {
    do {
        let destination = try FileManager.default.destinationOfSymbolicLink(atPath: url.path)
        let resolvedURL = URL(fileURLWithPath: destination)
        
        // Check if the resolved URL exists
        if FileManager.default.fileExists(atPath: resolvedURL.path) {
            return resolvedURL
        } else {
            print("Resolved symlink does not exist: \(resolvedURL.path)")
            return nil
        }
    } catch {
        print("Failed to resolve symlink: \(error.localizedDescription)")
        return nil
    }
}
}
