//
// ImageMetadataView.swift
//
// Created by Speedyfriend67 on 28.06.24
//
 
import SwiftUI
import ImageIO

struct ImageMetadataView: View {
    let fileURL: URL
    @State private var showMetadata = false
    @State private var metadata: [String: Any] = [:]
    @State private var image: UIImage?

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("Failed to load image")
            }
            Button(action: {
                showMetadata = true
            }) {
                Image(systemName: "info.circle")
                    .font(.largeTitle)
            }
            .padding()
            .sheet(isPresented: $showMetadata) {
                MetadataView(metadata: metadata)
            }
        }
        .onAppear {
            loadImageAndMetadata()
        }
        .navigationTitle(fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadImageAndMetadata() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: fileURL), let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }

            let options: NSDictionary = [:]
            guard let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, options) else {
                print("Cannot create image source")
                return
            }
            guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, options) as? [String: Any] else {
                print("Cannot copy image properties")
                return
            }
            DispatchQueue.main.async {
                self.metadata = imageProperties
            }
        }
    }
}

struct MetadataView: View {
    var metadata: [String: Any]

    var body: some View {
        NavigationView {
            List {
                ForEach(metadata.keys.sorted(), id: \.self) { key in
                    if let nestedMetadata = metadata[key] as? [String: Any] {
                        Section(header: Text(key)) {
                            ForEach(nestedMetadata.keys.sorted(), id: \.self) { nestedKey in
                                VStack(alignment: .leading) {
                                    Text(nestedKey)
                                        .font(.headline)
                                    Text(string(for: nestedMetadata[nestedKey]))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text(key)
                                .font(.headline)
                            Text(string(for: metadata[key]))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("Image Metadata")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func string(for value: Any?) -> String {
        if let value = value {
            return String(describing: value)
        } else {
            return "Unknown"
        }
    }
}

struct ImageMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        ImageMetadataView(fileURL: URL(fileURLWithPath: "/path/to/your/image.jpg"))
    }
}