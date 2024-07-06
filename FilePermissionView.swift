//
// FilePermissionView.swift
//
// Created by Speedyfriend67 on 30.06.24
//


// FilePermissionView.swift
//
// Created by Speedyfriend67 on 30.06.24
//

import SwiftUI

struct FilePermissionView: View {
    @ObservedObject var viewModel: FileManagerViewModel
    let fileURL: URL

    var body: some View {
        let metadata = viewModel.getFileMetadata(at: fileURL)
        
        return List {
            Section(header: Text("File Metadata")) {
                Text("Name: \(metadata.name)")
                Text("Size: \(metadata.size)")
                Text("Creation Date: \(metadata.creationDate)")
                Text("Modification Date: \(metadata.modificationDate)")
            }

            Section(header: Text("File Permissions")) {
                ForEach(FilePermission.allCases, id: \.self) { permission in
                    HStack {
                        Text(permission.rawValue)
                        Spacer()
                        Image(systemName: viewModel.isPermissionGranted(for: fileURL, permission: permission) ? "checkmark.square" : "square")
                            .onTapGesture {
                                viewModel.toggleFilePermission(at: fileURL, permission: permission)
                            }
                    }
                }
            }
        }
    }
}