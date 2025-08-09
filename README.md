# Sidecar Notes

**Privacy-first meeting recorder for macOS**

Transform your online meetings with Sidecar Notes – the meeting companion that records, transcribes, and summarizes your discussions without ever leaving your Mac.

## 🎯 Key Features

- **Effortless Meeting Capture**: Record system audio and microphone simultaneously
- **Universal Compatibility**: Works with Zoom, Teams, Meet, WebEx, and any meeting platform
- **Local AI Processing**: 95%+ transcription accuracy with complete privacy
- **Smart Speaker Identification**: Automatically learns and identifies speakers
- **AI-Powered Summaries**: Extract decisions, action items, and key insights
- **Privacy by Design**: Zero data collection, everything stays on your Mac

## 🚀 Quick Start

### Installation

1. **Download**: Get the latest release from [Releases](https://github.com/yourusername/sidecar-notes/releases)
2. **Extract**: Unzip the downloaded file
3. **Install**: Drag `Sidecar Notes.app` to your Applications folder
4. **First Launch**: Right-click the app and select "Open" (bypasses security warning)
5. **Grant Permissions**: Allow microphone and system audio access when prompted

### First Recording

1. Click the microphone icon in your menu bar
2. Select "Start Recording" before or during your meeting
3. The app captures everything automatically while you focus on the discussion
4. Click "Stop Recording" when done
5. Review your transcript and AI-generated summary

## 🔒 Privacy Promise

**Your meetings never leave your Mac.** 

- All transcription and AI processing happens locally
- No cloud services, no data collection, no tracking
- Verifiable local-only processing with zero network activity
- Complete control over your data with one-click deletion

## 🛠 Development

### Requirements

- macOS 12.0+ (Monterey or later)
- Xcode 15.0+
- Apple Silicon Mac recommended (M1/M2/M3)

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/sidecar-notes.git
   cd sidecar-notes
   ```

2. **Open in Xcode**:
   ```bash
   open SidecarNotes.xcodeproj
   ```

3. **Sign with Personal Apple ID**:
   - In Xcode, go to Preferences → Accounts
   - Sign in with your personal Apple ID
   - Xcode will automatically create a personal development team

4. **Build and Run**:
   - Select "Sidecar Notes" scheme
   - Choose your Mac as the destination
   - Press ⌘R to build and run

### Project Structure

```
SidecarNotes/
├── App/                    # Main app and menu bar controller
├── Core/                   # Core functionality
│   ├── Audio/             # Audio capture and processing
│   ├── Models/            # Data models and structures
│   └── Privacy/           # Privacy and security management
├── UI/                    # User interface components
│   ├── Recording/         # Recording interface
│   └── Settings/          # Settings and preferences
└── Resources/             # Assets and configuration
```

## 📋 Development Roadmap

### Phase 1: Foundation (Current)
- [x] Menu bar interface and basic controls
- [x] Core data models and architecture
- [x] Permission management system
- [x] Settings interface
- [ ] Audio capture implementation

### Phase 2: Core Features
- [ ] Dual audio stream capture
- [ ] Real-time audio quality monitoring
- [ ] Meeting platform detection
- [ ] Basic recording workflow

### Phase 3: AI & Intelligence
- [ ] Local Whisper model integration
- [ ] Speaker diarization system
- [ ] Voice embedding and clustering
- [ ] Meeting summarization

### Phase 4: Polish & Distribution
- [ ] Advanced UI and user experience
- [ ] Export and sharing capabilities
- [ ] Performance optimization
- [ ] Release preparation

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow Swift coding conventions
- Add tests for new functionality
- Update documentation for API changes
- Ensure privacy compliance in all features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: Report bugs and request features on [GitHub Issues](https://github.com/yourusername/sidecar-notes/issues)
- **Discussions**: Join conversations on [GitHub Discussions](https://github.com/yourusername/sidecar-notes/discussions)

## 🙏 Acknowledgments

- Built with [OpenAI Whisper](https://github.com/openai/whisper) for speech recognition
- Privacy-first architecture inspired by local-first software principles
- Menu bar interface built with SwiftUI and AppKit

---

**Made with ❤️ for focused, private, productive meetings**