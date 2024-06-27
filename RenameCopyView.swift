//
// RenameCopyView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import SwiftUI

struct RenameCopyView: View {
    @Binding var newName: String
    @Binding var isPresented: Bool
    var isRename: Bool
    var onComplete: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isRename ? "Rename Item" : "Copy Item")) {
                    TextField(isRename ? "New Name" : "Copy Name", text: $newName)
                }
            }
            .navigationTitle(isRename ? "Rename" : "Copy")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                onComplete(newName)
                isPresented = false
            })
        }
    }
}