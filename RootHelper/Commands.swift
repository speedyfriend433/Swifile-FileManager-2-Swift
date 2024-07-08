//
// Commands.swift
//
// Created by Speedyfriend67 on 30.06.24
//
 
import Foundation

func sendOutThisMessage() {
    print("""
    Usage: RootHelper [action] [path]
    Made by Le Bao Nguyen (@lebao3105 on GitHub and GitLab)
    Written in C++ and Pascal (2 different versions). Write once, run almost everywhere!
    (This C++ thing, in fact, mostly uses C things.)

    Available [action]s:
    del / d [path]                             : Deletes [path]
    list / l [path]                            : Shows the content [path]
    create / c [path]                          : Creates [path]
    createdir / md [path]                      : Creates [path] as a directory
    move / mv [path, list must not be odd]     : Moves files and folders
    copy / cp [path, list must not be odd]     : Copies files and folders to another location
    getuid / guid                              : Gets and shows the current UID
    getgid / gid                               : Gets and shows the current GID

    [path] can in any number of absolute paths that the program and system can handle.

    Warning: NO confirmation message. No success/progress message. You've been warned.
    """)
}

func isMod2Equal0(_ argc: Int) throws {
    if argc % 2 != 0 {
        throw NSError(domain: "Not enough arguments!", code: 1, userInfo: nil)
    }
}

func checkArg(_ arg: String, longarg: String, shortarg: String) -> Bool {
    return arg == longarg || arg == shortarg
}

func enoughArgs(_ argc: Int) throws {
    if argc <= 2 {
        sendOutThisMessage()
        throw NSError(domain: "Not enough arguments!", code: 1, userInfo: nil)
    }
}

func main() {
    let argc = Int(CommandLine.argc)
    let argv = CommandLine.arguments

    do {
        if checkArg(argv[1], longarg: "del", shortarg: "d") {
            try enoughArgs(argc)
            for i in 2..<argc {
                try FileManager.default.removeItem(atPath: argv[i])
            }
        } else if checkArg(argv[1], longarg: "list", shortarg: "l") {
            try enoughArgs(argc)
            for i in 2..<argc {
                let contents = try FileManager.default.contentsOfDirectory(atPath: argv[i])
                for content in contents {
                    print(content)
                }
            }
        } else if checkArg(argv[1], longarg: "create", shortarg: "c") {
            try enoughArgs(argc)
            for i in 2..<argc {
                FileManager.default.createFile(atPath: argv[i], contents: Data(), attributes: nil)
            }
        } else if checkArg(argv[1], longarg: "createdir", shortarg: "md") {
            try enoughArgs(argc)
            for i in 2..<argc {
                try FileManager.default.createDirectory(atPath: argv[i], withIntermediateDirectories: false, attributes: nil)
            }
        } else if checkArg(argv[1], longarg: "move", shortarg: "mv") {
            try enoughArgs(argc)
            try isMod2Equal0(argc)
            for i in stride(from: 2, to: argc, by: 2) {
                try FileManager.default.moveItem(atPath: argv[i], toPath: argv[i + 1])
            }
        } else if checkArg(argv[1], longarg: "copy", shortarg: "cp") {
            try enoughArgs(argc)
            try isMod2Equal0(argc)
            for i in stride(from: 2, to: argc, by: 2) {
                try FileManager.default.copyItem(atPath: argv[i], toPath: argv[i + 1])
            }
        } else if checkArg(argv[1], longarg: "getuid", shortarg: "guid") {
            print("UID: \(getuid())")
        } else if checkArg(argv[1], longarg: "getgid", shortarg: "gid") {
            print("GID: \(getgid())")
        } else {
            sendOutThisMessage()
            throw NSError(domain: "Unknown command used. Quit now.", code: 1, userInfo: nil)
        }
    } catch {
        print(error.localizedDescription)
    }
}
