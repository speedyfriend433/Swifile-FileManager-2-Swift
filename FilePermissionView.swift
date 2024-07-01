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
        VStack {
            Text("File Permissions")
                .font(.headline)
            List {
                ForEach(viewModel.getFilePermissions(at: fileURL), id: \.self) { permission in
                    HStack {
                        Text(permission)
                        Spacer()
                        Button(action: {
                            viewModel.toggleFilePermission(at: fileURL, permission: permission)
                        }) {
                            Text("Toggle")
                        }
                    }
                }
            }
        }
        .padding()
    }
}