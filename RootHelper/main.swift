//
// main.swift
//
// Created by Speedyfriend67 on 30.06.24
//
import Foundation
import Darwin

func help() {
    print("""
    Usage: RootHelper [action] [path]
    Proudly written in Swift. Write once, run everywhere!

    Available [action]s:
    del / d [path]                             : Deletes [path]
    list / l [path]                            : Shows the content [path]
    create / c [path]                          : Creates [path]
    createdir / md [path]                      : Creates [path] as a directory
    move / mv [path, list must not be odd]     : Moves files (FILES only for now)
    copy / cp [path, list must not be odd]     : Copies files (FILES only)
    getuid / guid                              : Gets and shows the current UID
    getgid / gid                               : Gets and shows the current GID

    [path] can be any number of absolute paths that the program and system can handle, in any kind: file and folder.

    This is MEANT to be used INTERNALLY by Swifile - a File manager.
    Any damages to the file system by you using this? You're the one who is responsible for it, not us.
    This project is a part of Swifile, licensed under the MIT license.
    """)
}

func moveItems(_ args: [String]) throws {
    guard (args.count - 1) % 2 == 0 else {
        throw FileOperationError.invalidPath
    }
    for i in stride(from: 1, to: args.count, by: 2) {
        try FileOperations.moveItem(from: args[i], to: args[i + 1])
    }
}

func copyItems(_ args: [String]) throws {
    guard (args.count - 1) % 2 == 0 else {
        throw FileOperationError.invalidPath
    }
    for i in stride(from: 1, to: args.count, by: 2) {
        try FileOperations.copyFile(from: args[i], to: args[i + 1])
    }
}

