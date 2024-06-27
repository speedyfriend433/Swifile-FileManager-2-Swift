//
// ImageFileView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import SwiftUI

struct ImageFileView: View {
    let fileURL: URL
    @State private var image: Image?
    @State private var isLoading: Bool = true
    @State private var showError: Bool = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if showError {
                Text("Failed to load image.")
                    .foregroundColor(.red)
            } else {
                image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
        }
        .onAppear(perform: loadImage)
        .navigationTitle(fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let uiImage = UIImage(contentsOfFile: fileURL.path) {
                DispatchQueue.main.async {
                    self.image = Image(uiImage: uiImage)
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showError = true
                }
            }
        }
    }
}

struct ImageFileView_Previews: PreviewProvider {
    static var previews: some View {
        ImageFileView(fileURL: URL(fileURLWithPath: "/var/tmp/sample.png"))
    }
}