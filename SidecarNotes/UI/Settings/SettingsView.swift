import SwiftUI

struct SettingsView: View {
    @State private var privacyMode: PrivacyMode = .maximum
    @State private var audioQualityMode: AudioQualityMode = .balanced
    @State private var showLiveCaptions = true
    @State private var autoStartProcessing = true
    @State private var dataRetentionDays = 180
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Sidecar Notes Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Configure your privacy-first meeting recorder")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Settings Tabs
            TabView {
                // Privacy Tab
                privacySettingsView
                    .tabItem {
                        Label("Privacy", systemImage: "lock.shield")
                    }
                
                // Audio Tab
                audioSettingsView
                    .tabItem {
                        Label("Audio", systemImage: "waveform")
                    }
                
                // General Tab
                generalSettingsView
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
                
                // About Tab
                aboutView
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Privacy Settings
    
    private var privacySettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                privacyModeSection
                dataManagementSection
                permissionsSection
            }
            .padding(.vertical)
        }
    }
    
    private var privacyModeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Mode")
                .font(.headline)
            
            Picker("Privacy Level", selection: $privacyMode) {
                ForEach(PrivacyMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            privacyModeDescription
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var privacyModeDescription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(privacyMode.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(privacyMode.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.headline)
            
            HStack {
                Text("Automatically delete recordings after:")
                Spacer()
                Picker("Retention", selection: $dataRetentionDays) {
                    Text("30 days").tag(30)
                    Text("90 days").tag(90)
                    Text("6 months").tag(180)
                    Text("1 year").tag(365)
                    Text("Never").tag(0)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Button("View Data Usage") {
                    // TODO: Show data usage window
                }
                .buttonStyle(.bordered)
                
                Button("Export All Data") {
                    // TODO: Export functionality
                }
                .buttonStyle(.bordered)
                
                Button("Delete All Data...") {
                    // TODO: Confirmation and deletion
                }
                .buttonStyle(.borderedProminent)
                .controlProminence(.increased)
                .tint(.red)
            }
        }
    }
    
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Permissions")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                PermissionRow(
                    title: "Microphone Access",
                    description: "Required to record your voice",
                    isGranted: true // TODO: Check actual permission status
                )
                
                PermissionRow(
                    title: "System Audio Access",
                    description: "Required to record meeting participants",
                    isGranted: false // TODO: Check actual permission status
                )
            }
            
            Button("Open System Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - Audio Settings
    
    private var audioSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                audioQualitySection
                captureSettingsSection
                enhancementSection
            }
            .padding(.vertical)
        }
    }
    
    private var audioQualitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recording Quality")
                .font(.headline)
            
            Picker("Quality Mode", selection: $audioQualityMode) {
                ForEach(AudioQualityMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            qualityModeDescription
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var qualityModeDescription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(audioQualityMode.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(audioQualityMode.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var captureSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Capture Settings")
                .font(.headline)
            
            Toggle("Show live captions during recording", isOn: $showLiveCaptions)
            
            Toggle("Automatically start processing after recording", isOn: $autoStartProcessing)
        }
    }
    
    private var enhancementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audio Enhancement")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Automatic noise reduction")
                Text("• Echo cancellation")
                Text("• Voice activity detection")
                Text("• Dynamic range optimization")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button("Test Audio Setup") {
                // TODO: Launch audio test
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - General Settings
    
    private var generalSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Additional settings will be available in future updates")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - About View
    
    private var aboutView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sidecar Notes")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0 (Development)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Privacy-first meeting recorder for macOS")
                        .font(.body)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✓ Local processing only - complete privacy")
                        Text("✓ Automatic transcription with 95%+ accuracy")
                        Text("✓ Smart speaker identification and learning")
                        Text("✓ AI-powered meeting summaries")
                        Text("✓ Universal meeting platform compatibility")
                        Text("✓ One-click export and sharing")
                    }
                    .font(.body)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Privacy Guarantee")
                        .font(.headline)
                    
                    Text("Your meeting data never leaves your Mac. All processing happens locally using on-device AI models. No cloud services, no data collection, no tracking.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Button("GitHub Repository") {
                        // TODO: Open GitHub repo
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Report Issue") {
                        // TODO: Open issue tracker
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Supporting Views

struct PermissionRow: View {
    let title: String
    let description: String
    let isGranted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isGranted ? .green : .red)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Enums

enum PrivacyMode: CaseIterable {
    case maximum
    case balanced
    
    var displayName: String {
        switch self {
        case .maximum: return "Maximum Privacy"
        case .balanced: return "Balanced"
        }
    }
    
    var description: String {
        switch self {
        case .maximum:
            return "Complete local processing with no network access. All AI models run on-device. Highest privacy and security."
        case .balanced:
            return "Local processing with optional cloud features disabled. Good balance of privacy and functionality."
        }
    }
}

enum AudioQualityMode: CaseIterable {
    case fast
    case balanced
    case highQuality
    
    var displayName: String {
        switch self {
        case .fast: return "Fast"
        case .balanced: return "Balanced"
        case .highQuality: return "High Quality"
        }
    }
    
    var description: String {
        switch self {
        case .fast:
            return "Optimized for speed. Good for quick transcriptions and shorter meetings."
        case .balanced:
            return "Best balance of speed and accuracy. Recommended for most meetings."
        case .highQuality:
            return "Maximum accuracy and detail. Best for important meetings and clear audio."
        }
    }
}

#Preview {
    SettingsView()
        .frame(width: 600, height: 500)
}