//
// FileDetailView.swift
//
// Created by Speedyfriend67 on 28.06.24
//
 
import SwiftUI

struct FileDetailView: View {
    var fileURL: URL

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Text(fileName)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                Text(fileDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(fileSize)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    shareFile()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .padding()
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("File Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFileDetails()
        }
    }

    @State private var fileName: String = ""
    @State private var fileDescription: String = ""
    @State private var fileSize: String = ""

    private func loadFileDetails() {
        fileName = fileURL.lastPathComponent
        fileDescription = fileURL.pathExtension.uppercased() + " File"

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attributes[.size] as? UInt64 {
                fileSize = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
            }
        } catch {
            fileSize = "Unknown size"
        }
    }

    private func shareFile() {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        if let topController = window?.rootViewController {
            topController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

struct FileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FileDetailView(fileURL: URL(fileURLWithPath: "/path/to/file.ipa"))
    }
}
