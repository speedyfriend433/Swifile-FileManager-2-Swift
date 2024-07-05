//
// UIViewControllerRepresentable.swift
//
// Created by Speedyfriend67 on 04.07.24
//
 
import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    let content: () -> Content
    let onRefresh: () -> Void

    init(@ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content
        self.onRefresh = onRefresh
    }

    var body: some View {
        ScrollView {
            content()
        }
        .refreshable {
            onRefresh()
        }
    }
}