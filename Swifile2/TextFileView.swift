//
// TextFileView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import SwiftUI

struct TextFileView: View {
    @State private var fileContent: String = ""
    @State private var isLoading: Bool = true
    @State private var showError: Bool = false
    let fileURL: URL

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if showError {
                Text("Failed to load file.")
                    .foregroundColor(.red)
            } else {
                TextEditor(text: $fileContent)
                    .padding()
                    .navigationBarItems(trailing: Button("Save") {
                        saveFile()
                    })
            }
        }
        .onAppear(perform: loadFile)
        .navigationTitle(fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                DispatchQueue.main.async {
                    self.fileContent = content
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showError = true
                }
            }
        }
    }

    private func saveFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.fileContent.write(to: self.fileURL, atomically: true, encoding: .utf8)
                DispatchQueue.main.async {
                    // You can show a success message or give feedback to the user if needed
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
        }
    }
}

struct TextFileView_Previews: PreviewProvider {
    static var previews: some View {
        TextFileView(fileURL: URL(fileURLWithPath: "/var/tmp/sample.txt"))
    }
}