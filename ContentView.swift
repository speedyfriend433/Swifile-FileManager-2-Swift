//
// ContentView.swift
//
// Created by Speedyfriend67 on 27.06.24
//
 
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            DirectoryView(directory: URL(fileURLWithPath: "/"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}