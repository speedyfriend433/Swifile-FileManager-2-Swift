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
                Text("Name: \(metadata["Name"] ?? "Unknown")")
                Text("Size: \(metadata["Size"] ?? "Unknown")")
                Text("Creation Date: \(metadata["Creation Date"] ?? "Unknown")")
                Text("Modification Date: \(metadata["Modification Date"] ?? "Unknown")")
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

                //Text(//"MIME Type: \(viewModel.getMIMEType(at: fileURL))")
                //Text(//"MD5: \(viewModel.getFileHash(at: fileURL, hashType: .md5))")
                //Text(//"SHA1: \(viewModel.getFileHash(at: fileURL, hashType: .sha1))")
                //Text(//"SHA256: \(viewModel.getFileHash(at: fileURL, hashType: .sha256))")
                //Text(//"Creation Date: \(viewModel.getCreationDate(at: fileURL))")
                //Text(//"Modification Date: \(viewModel.getModificationDate(at: fileURL))")
            