import AppKit
import SwiftUI
import AVFoundation

class MenuBarController: ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioQuality: AudioQualityStatus = .unknown
    @Published var permissionsGranted = false
    
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    
    // MARK: - Menu Creation
    
    func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Recording status item
        let statusItem = NSMenuItem(title: recordingStatusText, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Main recording control
        let recordingAction = isRecording ? "Stop Recording" : "Start Recording"
        let recordingItem = NSMenuItem(title: recordingAction, action: #selector(toggleRecording), keyEquivalent: "r")
        recordingItem.target = self
        recordingItem.keyEquivalentModifierMask = .command
        menu.addItem(recordingItem)
        
        // Test audio
        let testAudioItem = NSMenuItem(title: "Test Audio", action: #selector(testAudioSetup), keyEquivalent: "t")
        testAudioItem.target = self
        testAudioItem.keyEquivalentModifierMask = .command
        menu.addItem(testAudioItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Recent meetings
        let recentMeetingsItem = NSMenuItem(title: "Recent Meetings", action: #selector(showRecentMeetings), keyEquivalent: "")
        recentMeetingsItem.target = self
        menu.addItem(recentMeetingsItem)
        
        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.keyEquivalentModifierMask = .command
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // About
        let aboutItem = NSMenuItem(title: "About Sidecar Notes", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit Sidecar Notes", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)
        
        return menu
    }
    
    // MARK: - Actions
    
    @objc func statusBarItemClicked() {
        // This will be called when the status bar item is clicked
        // The menu will automatically show
    }
    
    @objc func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @objc func testAudioSetup() {
        Task {
            await checkAndRequestPermissions()
        }
    }
    
    @objc func showRecentMeetings() {
        // TODO: Implement recent meetings window
        showNotImplementedAlert("Recent Meetings")
    }
    
    @objc func showSettings() {
        // Open Settings window
        if let window = NSApp.windows.first(where: { $0.title.contains("Settings") }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // Create new settings window if none exists
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Sidecar Notes Settings"
            window.setContentSize(NSSize(width: 600, height: 500))
            window.center()
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Sidecar Notes"
        alert.informativeText = """
        Version 1.0.0
        
        Privacy-first meeting recorder for macOS
        
        • Local processing only - your data never leaves your Mac
        • Automatic transcription and speaker identification
        • AI-powered meeting summaries and action items
        • Compatible with all meeting platforms
        
        Built with ❤️ for focused productivity
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func quitApp() {
        if isRecording {
            let alert = NSAlert()
            alert.messageText = "Recording in Progress"
            alert.informativeText = "A recording is currently in progress. Do you want to stop and save it before quitting?"
            alert.addButton(withTitle: "Stop & Save")
            alert.addButton(withTitle: "Discard Recording")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            switch response {
            case .alertFirstButtonReturn:
                stopRecording()
                NSApp.terminate(nil)
            case .alertSecondButtonReturn:
                NSApp.terminate(nil)
            case .alertThirdButtonReturn:
                return // Cancel quit
            default:
                break
            }
        } else {
            NSApp.terminate(nil)
        }
    }
    
    // MARK: - Recording Management
    
    private func startRecording() {
        Task {
            let hasPermissions = await checkAndRequestPermissions()
            
            await MainActor.run {
                if hasPermissions {
                    isRecording = true
                    recordingStartTime = Date()
                    recordingDuration = 0
                    
                    // Start recording timer
                    recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                        self?.updateRecordingDuration()
                    }
                    
                    // TODO: Start actual audio recording
                    print("🎙️ Started recording")
                    updateMenuBarIcon()
                } else {
                    showPermissionsAlert()
                }
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // TODO: Stop actual audio recording and process
        print("⏹️ Stopped recording - Duration: \(recordingDuration) seconds")
        updateMenuBarIcon()
        
        // Show processing notification
        let notification = NSUserNotification()
        notification.title = "Recording Saved"
        notification.informativeText = "Processing your meeting transcript and summary..."
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func updateRecordingDuration() {
        guard let startTime = recordingStartTime else { return }
        recordingDuration = Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Audio Permissions
    
    private func checkAndRequestPermissions() async -> Bool {
        // Check microphone permission
        let microphonePermission = await requestMicrophonePermission()
        
        // Check system audio permission (requires screen recording permission)
        let systemAudioPermission = await requestSystemAudioPermission()
        
        let hasAllPermissions = microphonePermission && systemAudioPermission
        
        await MainActor.run {
            self.permissionsGranted = hasAllPermissions
        }
        
        return hasAllPermissions
    }
    
    private func requestMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    private func requestSystemAudioPermission() async -> Bool {
        // For system audio capture, we need screen recording permission
        // This is a limitation of macOS security model
        
        // TODO: Implement proper screen recording permission check
        // For now, return true and handle in actual audio capture implementation
        return true
    }
    
    private func showPermissionsAlert() {
        let alert = NSAlert()
        alert.messageText = "Permissions Required"
        alert.informativeText = """
        Sidecar Notes needs access to:
        
        • Microphone - to record your voice
        • System Audio - to record meeting participants
        
        Please grant these permissions in System Settings > Privacy & Security.
        """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open System Settings to Privacy & Security
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
        }
    }
    
    // MARK: - UI Updates
    
    private func updateMenuBarIcon() {
        guard let button = NSApp.statusBarItem?.button else { return }
        
        let iconName = isRecording ? "mic.fill" : "mic"
        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Sidecar Notes")
        
        // Change tint color when recording
        if isRecording {
            button.image?.isTemplate = false
            // TODO: Add red tint for recording state
        } else {
            button.image?.isTemplate = true
        }
    }
    
    private var recordingStatusText: String {
        if isRecording {
            let minutes = Int(recordingDuration) / 60
            let seconds = Int(recordingDuration) % 60
            return "Recording \(String(format: "%02d:%02d", minutes, seconds))"
        } else {
            return "Ready to Record"
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        recordingTimer?.invalidate()
        if isRecording {
            stopRecording()
        }
    }
    
    // MARK: - Helper Methods
    
    private func showNotImplementedAlert(_ feature: String) {
        let alert = NSAlert()
        alert.messageText = "\(feature) - Coming Soon"
        alert.informativeText = "This feature is being implemented and will be available in a future update."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Audio Quality Status

enum AudioQualityStatus {
    case unknown
    case excellent
    case good
    case acceptable
    case poor
    
    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .acceptable: return "Acceptable"
        case .poor: return "Poor"
        }
    }
    
    var color: NSColor {
        switch self {
        case .excellent: return .systemGreen
        case .good: return .systemBlue
        case .acceptable: return .systemYellow
        case .poor: return .systemRed
        case .unknown: return .systemGray
        }
    }
}