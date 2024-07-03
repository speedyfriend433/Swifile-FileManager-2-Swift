//
// HideKeyboard.swift
//
// Created by Speedyfriend67 on 30.06.24
//
 
import SwiftUI

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}