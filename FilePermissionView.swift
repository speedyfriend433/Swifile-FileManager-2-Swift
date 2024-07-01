//
// FilePermissionView.swift
//
// Created by Speedyfriend67 on 30.06.24
//

import SwiftUI

struct FilePermissionView: View {
    @ObservedObject var viewModel: FileManagerViewModel
    var fileURL: URL

    var body: some View {
        List(FilePermission.allCases, id: \.self) { permission in
            HStack {
                Image(systemName: viewModel.isPermissionGranted(for: fileURL, permission: permission) ? "checkmark.square" : "square")
                    .onTapGesture {
                        viewModel.toggleFilePermission(at: fileURL, permission: permission)
                    }
                Text(permission.rawValue)
            }
        }
    }
}