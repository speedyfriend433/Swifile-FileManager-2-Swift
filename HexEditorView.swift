//
// HexEditorView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import SwiftUI

struct HexEditorView: View {
    @State private var fileContent: [UInt8] = []
    @State private var isLoading: Bool = true
    @State private var showError: Bool = false
    @State private var searchText: String = ""
    @State private var jumpToAddress: String = ""
    @State private var searchResults: [Int] = []
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
                HeaderView(searchText: $searchText, jumpToAddress: $jumpToAddress, onSearch: search)
                
                ScrollViewReader { scrollView in
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 1) {
                            ForEach(0..<fileContent.count / 8, id: \.self) { row in
                                let address = row * 8
                                RowView(index: address, fileContent: $fileContent, searchResults: searchResults)
                                    .id(address)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .background(Color.black)
                    .onChange(of: jumpToAddress) { newValue in
                        if let address = Int(newValue, radix: 16) {
                            withAnimation {
                                scrollView.scrollTo(address, anchor: .top)
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadFile)
        .navigationTitle(fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: fileURL)
                DispatchQueue.main.async {
                    self.fileContent = Array(data)
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

    private func search() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        let searchBytes = Array(searchText.utf8)
        searchResults = []

        for index in 0...(fileContent.count - searchBytes.count) {
            if Array(fileContent[index..<(index + searchBytes.count)]) == searchBytes {
                searchResults.append(contentsOf: index..<(index + searchBytes.count))
            }
        }
    }
}

struct HeaderView: View {
    @Binding var searchText: String
    @Binding var jumpToAddress: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            TextField("Start search here", text: $searchText, onCommit: onSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            TextField("Go to address", text: $jumpToAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button(action: {
                if Int(jumpToAddress, radix: 16) != nil {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // Dismiss the keyboard
                }
                onSearch()
            }) {
                Image(systemName: "magnifyingglass")
            }
            .padding(.horizontal)
        }
    }
}

struct RowView: View {
    let index: Int
    @Binding var fileContent: [UInt8]
    let searchResults: [Int]

    var body: some View {
        HStack(spacing: 1) {
            Text(String(format: "%08X", index))
                .foregroundColor(.blue)
                .frame(width: 60, alignment: .leading)
            ForEach(0..<8, id: \.self) { offset in
                let currentIndex = index + offset
                if currentIndex < fileContent.count {
                    TextField("", text: Binding(
                        get: {
                            String(format: "%02X", fileContent[currentIndex])
                        },
                        set: { newValue in
                            if let byte = UInt8(newValue, radix: 16) {
                                fileContent[currentIndex] = byte
                            }
                        }
                    ))
                    .foregroundColor(searchResults.contains(currentIndex) ? .yellow : .white)
                    .frame(width: 24, alignment: .leading)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                } else {
                    Text("  ")
                        .frame(width: 24, alignment: .leading)
                }
            }
            Spacer()
            ForEach(0..<8, id: \.self) { offset in
                let currentIndex = index + offset
                if currentIndex < fileContent.count {
                    let char = fileContent[currentIndex] >= 32 && fileContent[currentIndex] < 127 ? Character(UnicodeScalar(fileContent[currentIndex])) : "."
                    Text(String(char))
                        .foregroundColor(searchResults.contains(currentIndex) ? .yellow : .blue)
                        .frame(width: 12, alignment: .leading)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                } else {
                    Text(" ")
                        .frame(width: 12, alignment: .leading)
                }
            }
        }
        .font(.system(size: 12, weight: .regular, design: .monospaced))
    }
}

struct HexEditorView_Previews: PreviewProvider {
    static var previews: some View {
        HexEditorView(fileURL: URL(fileURLWithPath: "/path/to/file"))
    }
}
