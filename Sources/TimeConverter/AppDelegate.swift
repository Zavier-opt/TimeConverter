import Cocoa
import SwiftUI
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var hotKey: HotKey?
    private var windowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupStatusBar()
        setupHotKey()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "TimeConverter")
            button.action = #selector(toggleWindow)
            button.target = self
        }
    }
    
    private func setupHotKey() {
        hotKey = HotKey(key: .space, modifiers: [.command, .shift])
        hotKey?.keyDownHandler = { [weak self] in
            self?.toggleWindow()
        }
    }
    
    private func setupWindow() {
        // Create the window if it doesn't exist
        if windowController == nil {
            let contentView = ContentView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            window.contentView = NSHostingView(rootView: contentView)
            window.title = "Time Converter"
            window.minSize = NSSize(width: 500, height: 400)
            window.center()
            
            // Create window controller to manage the window
            windowController = NSWindowController(window: window)
        }
        
        showWindow()
    }
    
    private func showWindow() {
        windowController?.showWindow(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    @objc private func toggleWindow() {
        guard let window = windowController?.window else {
            setupWindow()
            return
        }
        
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.center()
            showWindow()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showWindow()
        }
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        windowController = nil
        statusItem = nil
        hotKey = nil
    }
} 