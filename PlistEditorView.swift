//
// PlistEditorView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import SwiftUI

struct PlistEditorView: View {
    @State private var plistContent: [String: Any] = [:]
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
                List {
                    ForEach(plistContent.keys.sorted(), id: \.self) { key in
                        HStack {
                            Text(key)
                                .font(.headline)
                            Spacer()
                            valueView(for: key, value: plistContent[key]!)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarItems(trailing: Button(action: saveFile) {
                    Text("Save")
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
                let data = try Data(contentsOf: fileURL)
                if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.plistContent = plist
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showError = true
                    }
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
                let data = try PropertyListSerialization.data(fromPropertyList: self.plistContent, format: .xml, options: 0)
                try data.write(to: self.fileURL)
                DispatchQueue.main.async {
                    // Provide feedback to the user if needed
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
        }
    }

    @ViewBuilder
    private func valueView(for key: String, value: Any) -> some View {
        if let stringValue = value as? String {
            TextField("", text: Binding(
                get: { stringValue },
                set: { plistContent[key] = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } else if let numberValue = value as? NSNumber {
            TextField("", value: Binding(
                get: { numberValue },
                set: { plistContent[key] = $0 }
            ), formatter: NumberFormatter())
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } else if let boolValue = value as? Bool {
            Toggle("", isOn: Binding(
                get: { boolValue },
                set: { plistContent[key] = $0 }
            ))
        } else if let arrayValue = value as? [Any] {
            NavigationLink(destination: PlistArrayView(array: Binding(
                get: { arrayValue },
                set: { plistContent[key] = $0 }
            ))) {
                Text("Array (\(arrayValue.count))")
            }
        } else if let dictValue = value as? [String: Any] {
            NavigationLink(destination: NestedPlistEditorView(plistContent: Binding(
                get: { dictValue },
                set: { plistContent[key] = $0 }
            ))) {
                Text("Dictionary (\(dictValue.count))")
            }
        } else {
            EmptyView()
        }
    }
}

struct PlistArrayView: View {
    @Binding var array: [Any]
    var body: some View {
        List {
            ForEach(array.indices, id: \.self) { index in
                if let stringValue = array[index] as? String {
                    TextField("", text: Binding(
                        get: { stringValue },
                        set: { array[index] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else if let numberValue = array[index] as? NSNumber {
                    TextField("", value: Binding(
                        get: { numberValue },
                        set: { array[index] = $0 }
                    ), formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else if let boolValue = array[index] as? Bool {
                    Toggle("", isOn: Binding(
                        get: { boolValue },
                        set: { array[index] = $0 }
                    ))
                } else if let arrayValue = array[index] as? [Any] {
                    NavigationLink(destination: PlistArrayView(array: Binding(
                        get: { arrayValue },
                        set: { array[index] = $0 }
                    ))) {
                        Text("Array (\(arrayValue.count))")
                    }
                } else if let dictValue = array[index] as? [String: Any] {
                    NavigationLink(destination: NestedPlistEditorView(plistContent: Binding(
                        get: { dictValue },
                        set: { array[index] = $0 }
                    ))) {
                        Text("Dictionary (\(dictValue.count))")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Array")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NestedPlistEditorView: View {
    @Binding var plistContent: [String: Any]

    var body: some View {
        List {
            ForEach(plistContent.keys.sorted(), id: \.self) { key in
                HStack {
                    Text(key)
                        .font(.headline)
                    Spacer()
                    valueView(for: key, value: plistContent[key]!)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Dictionary")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func valueView(for key: String, value: Any) -> some View {
        if let stringValue = value as? String {
            TextField("", text: Binding(
                get: { stringValue },
                set: { plistContent[key] = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } else if let numberValue = value as? NSNumber {
            TextField("", value: Binding(
                get: { numberValue },
                set: { plistContent[key] = $0 }
            ), formatter: NumberFormatter())
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } else if let boolValue = value as? Bool {
            Toggle("", isOn: Binding(
                get: { boolValue },
                set: { plistContent[key] = $0 }
            ))
        } else if let arrayValue = value as? [Any] {
            NavigationLink(destination: PlistArrayView(array: Binding(
                get: { arrayValue },
                set: { plistContent[key] = $0 }
            ))) {
                Text("Array (\(arrayValue.count))")
            }
        } else if let dictValue = value as? [String: Any] {
            NavigationLink(destination: NestedPlistEditorView(plistContent: Binding(
                get: { dictValue },
                set: { plistContent[key] = $0 }
            ))) {
                Text("Dictionary (\(dictValue.count))")
            }
        } else {
            EmptyView()
        }
    }
}

struct PlistEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PlistEditorView(fileURL: URL(fileURLWithPath: "/var/tmp/sample.plist"))
    }
}