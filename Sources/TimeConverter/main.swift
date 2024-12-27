import SwiftUI
import AppKit

// Ensure proper application setup
NSApplication.shared.setActivationPolicy(.regular)

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv) 