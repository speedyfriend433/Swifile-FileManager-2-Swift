import Foundation
import Darwin

@discardableResult
func shell(_ command: String, asRoot: Bool = false) -> Int {
    if asRoot {
        guard let rootPath = findJBRoot() else {
            print("Jailbreak root not found")
            return -1
        }
        return runCommand("/usr/bin/bash", ["-c", command], 0, rootPath)
    } else {
        return runCommand("/usr/bin/bash", ["-c", command], 501)
    }
}

// Define C functions
@_silgen_name("posix_spawnattr_set_persona_np")
func posix_spawnattr_set_persona_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t, _ flags: UInt32) -> Int32
@_silgen_name("posix_spawnattr_set_persona_uid_np")
func posix_spawnattr_set_persona_uid_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t) -> Int32
@_silgen_name("posix_spawnattr_set_persona_gid_np")
func posix_spawnattr_set_persona_gid_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t) -> Int32

// Function to spawn executables
func runCommand(_ command: String, _ args: [String], _ uid: uid_t, _ rootPath: String = "") -> Int {
    var pid: pid_t = 0
    let args: [String] = [String(command.split(separator: "/").last!)] + args
    let argv: [UnsafeMutablePointer<CChar>?] = args.map { $0.withCString(strdup) }
    let env = ["PATH=/usr/local/sbin:\(rootPath)/usr/local/sbin:/usr/local/bin:\(rootPath)/usr/local/bin:/usr/sbin:\(rootPath)/usr/sbin:/usr/bin:\(rootPath)/usr/bin:/sbin:\(rootPath)/sbin:/bin:\(rootPath)/bin:/usr/bin/X11:\(rootPath)/usr/bin/X11:/usr/games:\(rootPath)/usr/games"]
    let proenv: [UnsafeMutablePointer<CChar>?] = env.map { $0.withCString(strdup) }
    defer { for case let pro? in proenv { free(pro) } }
    var attr: posix_spawnattr_t?
    posix_spawnattr_init(&attr)
    _ = posix_spawnattr_set_persona_np(&attr, 99, 1)
    _ = posix_spawnattr_set_persona_uid_np(&attr, uid)
    _ = posix_spawnattr_set_persona_gid_np(&attr, uid)
    guard posix_spawn(&pid, rootPath + command, nil, &attr, argv + [nil], proenv + [nil]) == 0 else {
        print("Failed to spawn process")
        return -1
    }
    var status: Int32 = 0
    waitpid(pid, &status, 0)
    return Int(status)
}

// Function to find the jailbreak root
func findJBRoot() -> String? {
    if FileManager.default.fileExists(atPath: "/usr/bin/bash") {
        return ""
    } else if FileManager.default.fileExists(atPath: "/var/jb/usr/bin/bash") {
        return "/var/jb"
    } else {
        do {
            let applicationsPath = "/var/containers/Bundle/Application"
            if let jbRoot = try FileManager.default.contentsOfDirectory(atPath: applicationsPath).first(where: { $0.hasPrefix(".jbroot") }) {
                return "\(applicationsPath)/\(jbRoot)"
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
}

// Main function to run the example
func main() {
    print("Running shell command as root...")
    let result = shell("whoami", asRoot: true)
    print("Command exited with status \(result)")
}
