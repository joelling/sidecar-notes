import SwiftUI
import AppKit

@main
struct SidecarNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var menuBarController: MenuBarController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - this is a menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        // Create menu bar controller
        menuBarController = MenuBarController()
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic", accessibilityDescription: "Sidecar Notes")
            button.target = menuBarController
            button.action = #selector(MenuBarController.statusBarItemClicked)
        }
        
        statusItem.menu = menuBarController.createMenu()
        
        // Set up menu bar icon updates
        menuBarController.statusItem = statusItem
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up any active recordings
        menuBarController?.cleanup()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When user clicks dock icon (if visible), show menu instead
        menuBarController?.statusBarItemClicked()
        return true
    }
}