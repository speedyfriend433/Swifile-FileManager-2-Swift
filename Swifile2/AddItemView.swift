//
// AddItemView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import SwiftUI

struct AddItemView: View {
    @State private var itemName: String = ""
    @State private var showAlert = false
    @Binding var isPresented: Bool
    var isDirectory: Bool
    var existingNames: [String]
    var onComplete: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isDirectory ? "New Folder Name" : "New File Name")) {
                    TextField(isDirectory ? "Folder Name" : "File Name", text: $itemName)
                }
            }
            .navigationTitle(isDirectory ? "New Folder" : "New File")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                if itemName.isEmpty || existingNames.contains(itemName) {
                    showAlert = true
                } else {
                    onComplete(itemName)
                    isPresented = false
                }
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Name"),
                    message: Text("Please provide a unique and non-empty name."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}