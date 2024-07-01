//
// FilePermissionView.swift
//
// Created by Speedyfriend67 on 30.06.24
//

import SwiftUI

enum FilePermission: String, CaseIterable {
    case read
    case write
    case execute
}

struct FilePermissionView: View {
    @ObservedObject var viewModel: FileManagerViewModel
    var fileURL: URL

    var body: some View {
        VStack {
            Text("File Permissions for \(fileURL.lastPathComponent)")
                .font(.headline)
            ForEach(FilePermission.allCases, id: \.self) { permission in
                HStack {
                    Text(permission.rawValue.capitalized)
                    Spacer()
                    Button(action: {
                        viewModel.toggleFilePermission(at: fileURL, permission: permission)
                    }) {
                        Image(systemName: viewModel.isPermissionGranted(for: fileURL, permission: permission) ? "checkmark.square" : "square")
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}
