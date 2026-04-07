<div align="center">

# 🚀 ClarifyThis

**Your Intelligent AI Learning Companion for macOS**

[![macOS](https://img.shields.io/badge/macOS-11.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-yellow.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Instant explanations for anything on your screen — powered by AI, secured by design.*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Configuration](#%EF%B8%8F-configuration) • [Security](#-security)

---

</div>

## 📖 About

**ClarifyThis** is a powerful macOS productivity tool that brings AI-powered explanations directly to your workflow. Select any text, take a screenshot, or use voice input — and get instant, clear explanations without leaving your current application.

Perfect for:
- 🎓 **Students** learning complex topics
- 💼 **Professionals** researching new concepts
- 👨‍💻 **Developers** understanding code snippets
- 🌐 **Language learners** translating and understanding content
- 🤔 **Curious minds** exploring anything on their screen

---

## ✨ Features

### 🎯 Core Features

#### **📸 Screenshot Capture & OCR**
- Capture any region of your screen with a customizable hotkey
- Advanced OCR extracts text from images, PDFs, and screenshots
- Automatically explains the captured content using AI

#### **🗣️ Voice Input**
- Speak your questions naturally with voice recognition
- Real-time audio visualization during recording
- Hands-free learning experience

#### **💬 Intelligent AI Explanations**
- Powered by multiple AI providers (OpenRouter, Groq)
- Context-aware responses that adapt to your level
- Support for:
  - **LaTeX** mathematical formulas
  - **Chemistry** equations
  - **Code** syntax highlighting
  - **Interactive graphs** and charts
  - **Tables** and structured data

#### **🧠 Context Vault**
- Store personal background information (interests, education, preferences)
- AI personalizes explanations based on your context
- Encrypted cloud sync across devices
- Enable/disable specific context items on the fly

#### **📜 Conversation History**
- Automatic cloud-synced chat history
- Resume conversations seamlessly
- Export conversations to PDF
- Auto-delete old history (configurable retention)

#### **🎨 Beautiful UI**
- Native macOS design with smooth animations
- Dark/Light mode support
- Frosted glass effects (customizable)
- Minimized mode for distraction-free learning
- Custom LaTeX color themes

### 🔐 Privacy & Security

- **End-to-End Encryption**: All user data encrypted before cloud storage
- **Secure Authentication**: Firebase Auth with Google Sign-In
- **Local Processing**: OCR and audio processing done on-device
- **Environment Variables**: API keys never hardcoded
- **Auto-Updates**: Sparkle framework for secure updates

### ⚙️ Customization

- **Hotkey Configuration**: Set custom keyboard shortcuts for all actions
- **AI Provider Selection**: Choose between OpenRouter (Xiaomi) or Groq (Llama)
- **Auto-scroll**: Configurable scrolling during AI responses
- **Audio Ducking**: Automatically lower system audio during voice input
- **Launch at Login**: Optional startup integration
- **Continuity Mode**: Maintain conversation context across sessions

---

## 🖼️ Screenshots

<img width="1108" height="846" alt="Screenshot 2026-01-23 at 7 39 31 PM" src="https://github.com/user-attachments/assets/4e471db3-4e82-456d-91e7-574f7b17c6dc" />
<img width="512" height="703" alt="Screenshot 2026-01-22 at 12 38 09 PM" src="https://github.com/user-attachments/assets/540ec647-05af-44f3-bfb1-452f5d57cc54" />
<img width="539" height="701" alt="Screenshot 2026-01-22 at 12 40 17 PM" src="https://github.com/user-attachments/assets/2e222ce4-405f-462f-bd10-8843717a36f0" />
<img width="532" height="706" alt="Screenshot 2026-01-22 at 12 39 19 PM" src="https://github.com/user-attachments/assets/5d304662-4eee-4966-b0bf-b8c41ded3c75" />



---

## 📋 Requirements

- **macOS**: 11.0 (Big Sur) or later
- **Internet**: Required for AI processing
- **Microphone**: Optional, for voice input features
- **Firebase Account**: Required for cloud sync (setup instructions below)

---

## 🚀 Installation

### Option 1: Pre-built Binary (Recommended)

1. Download the latest release from [Releases](https://github.com/manchikantithanush-netizen/ClarifyThis/releases)
2. Drag **ClarifyThis.app** to your Applications folder
3. On first launch, right-click and select "Open" to bypass Gatekeeper

### Option 2: Build from Source

#### Prerequisites

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Clone and Build

```bash
# Clone the repository
git clone https://github.com/manchikantithanush-netizen/ClarifyThis.git
cd ClarifyThis

# Install dependencies (if using CocoaPods)
pod install

# Open in Xcode
open ClarifyThisv2.xcodeproj
```

---

## ⚙️ Configuration

### 1. API Keys Setup

ClarifyThis requires API keys for AI functionality. **Never commit these to version control!**

#### Create Environment File

```bash
# Copy the example file
cp .env.example .env

# Edit with your keys
nano .env
```

#### Add Your API Keys

```bash
# OpenRouter API Key (get from https://openrouter.ai/)
OPENROUTER_API_KEY=sk-or-v1-your-key-here

# Groq API Key (get from https://console.groq.com/)
GROQ_API_KEY=gsk_your-key-here
```

#### Get API Keys

1. **OpenRouter** (Xiaomi Model - Free Tier Available)
   - Visit: https://openrouter.ai/
   - Sign up and navigate to Settings → API Keys
   - Create a new key

2. **Groq** (Llama Model - Fast & Free)
   - Visit: https://console.groq.com/
   - Sign up and go to API Keys
   - Generate a new key

### 2. Firebase Setup (For Cloud Sync)

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable **Authentication** (Email/Password & Google Sign-In)
   - Enable **Cloud Firestore**

2. **Download Configuration**
   - In Project Settings → General
   - Download `GoogleService-Info.plist` for iOS
   - Place it in: `ClarifyThisv2/` directory

3. **Configure Firestore Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

4. **Security (Important!)**
   - Restrict your API key in Google Cloud Console
   - Add your app's bundle ID to allowed domains
   - See [SECURITY.md](SECURITY.md) for detailed security guidelines

### 3. Xcode Configuration

1. Open `ClarifyThisv2.xcodeproj` in Xcode
2. Select your development team in **Signing & Capabilities**
3. Update the **Bundle Identifier** if needed
4. Build and run (⌘R)

---

## 🎮 Usage

### Quick Start

1. **Launch ClarifyThis**
   - The app runs in your menu bar
   - Click the icon to open the main window

2. **Set Up Hotkeys** (Default)
   - **⌘ + Shift + S**: Screenshot & Explain
   - **⌘ + Shift + V**: Voice Input
   - Customize in Settings → Shortcuts

3. **Create Context** (Optional but Recommended)
   - Open Settings → Context Vault
   - Add information about yourself (education, interests, learning style)
   - AI will personalize explanations based on your context

### Basic Workflows

#### 📸 Explain Something on Screen

```
1. Press ⌘ + Shift + S
2. Select the area to capture
3. Wait for OCR to extract text
4. Get AI explanation instantly!
```

#### 🗣️ Ask a Question via Voice

```
1. Press ⌘ + Shift + V
2. Speak your question
3. Release when done
4. View AI response in overlay
```

#### 💬 Continue Conversation

```
1. Type follow-up questions in the input bar
2. Enable "Continuity Mode" to maintain context
3. AI remembers the conversation flow
```

#### 📊 Request Visualizations

```
Example prompts:
- "Show me a graph of y = x²"
- "Create a bar chart comparing GDP of USA, China, India"
- "Visualize the sine and cosine functions"
```

### Advanced Features

#### Context Vault Management

The Context Vault personalizes AI responses:

```swift
Example Context Items:
- "I'm a computer science student at MIT, junior year"
- "Explain things concisely with code examples"
- "I prefer Python over other languages"
- "I'm familiar with data structures and algorithms"
```

#### PDF Export

```
1. View conversation history
2. Select a conversation
3. Click "Export to PDF"
4. Choose save location
```

#### Auto-Delete Old History

```
Settings → Account → Auto-Delete History
- Keep for 7/30/90 days
- Or never delete
```

---

## 🏗️ Tech Stack

### Core Technologies

- **Language**: Swift 5.9
- **Framework**: SwiftUI
- **Minimum OS**: macOS 11.0+

### AI & Backend

- **AI Providers**: 
  - OpenRouter (Xiaomi Mimo v2)
  - Groq (Llama 4 Scout)
- **Backend**: Firebase
  - Authentication (Email/Password, Google Sign-In)
  - Cloud Firestore (Data sync)
  - Cloud Functions (Optional)

### Key Features Implementation

- **OCR**: Vision framework (on-device)
- **Speech Recognition**: AVFoundation (on-device)
- **Encryption**: CryptoKit (AES-GCM)
- **Hotkeys**: Carbon framework
- **Updates**: Sparkle framework
- **Markdown Rendering**: SwiftUI + AttributedString
- **LaTeX Rendering**: MathJax via WebKit
- **Charts**: Chart.js integration

### Dependencies

```swift
// Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

// Google Sign-In
import GoogleSignIn

// Apple Frameworks
import SwiftUI
import Vision
import AVFoundation
import CryptoKit
```

---

## 📂 Project Structure

```
ClarifyThisv2/
├── App/
│   ├── main.swift              # App entry point
│   ├── AppDelegate.swift       # App lifecycle
│   └── AboutWindow.swift       # About dialog
├── Features/
│   ├── Auth/                   # Login/Signup
│   ├── Explanation/            # Main explanation UI
│   ├── Voice/                  # Voice input
│   ├── Overlay/                # Floating panels
│   ├── Home/                   # Settings, History, Stats
│   └── StatusBar/              # Menu bar controller
├── Services/
│   ├── ConfigManager.swift     # API key management
│   ├── FirebaseManager.swift   # Auth & Firestore
│   ├── LLMClient.swift         # AI providers
│   ├── OCR.swift               # Text recognition
│   ├── EncryptionManager.swift # Data encryption
│   ├── ContextManager.swift    # Context vault
│   ├── AudioRecorder.swift     # Voice recording
│   ├── Screenshotter.swift     # Screen capture
│   └── ...
├── UIComponents/               # Reusable UI elements
├── Utilities/                  # Helper functions
└── WebResources/              # HTML/JS for rendering
```

---

## 🔒 Security

ClarifyThis takes security seriously:

### ✅ Security Measures

- **Encrypted Storage**: All user data encrypted with AES-256-GCM
- **Secure Keys**: User-specific encryption keys derived from Firebase UID
- **Environment Variables**: API keys loaded from `.env` file (never committed)
- **Firebase Rules**: Strict read/write permissions per user
- **On-Device Processing**: OCR and speech recognition never leave your Mac
- **HTTPS Only**: All network communication encrypted
- **No Telemetry**: No tracking or analytics without consent

### ⚠️ Important Notes

1. **Never commit** `.env` or `GoogleService-Info.plist` to version control
2. **Regenerate API keys** if exposed (see [SECURITY.md](SECURITY.md))
3. **Restrict Firebase API keys** in Google Cloud Console
4. **Enable Firestore security rules** before production use

For detailed security guidelines, see [SECURITY.md](SECURITY.md).

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) first.

### Development Setup

```bash
# Fork and clone
git clone https://github.com/your-username/ClarifyThis.git
cd ClarifyThis

# Create feature branch
git checkout -b feature/amazing-feature

# Make changes and test
open ClarifyThisv2.xcodeproj

# Commit with clear message
git commit -m "Add amazing feature"

# Push and create PR
git push origin feature/amazing-feature
```

### Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftUI for all UI code
- Document public APIs with DocC comments
- Write unit tests for business logic

---

## 📝 Roadmap

- [ ] **iOS Companion App** (Universal clipboard sync)
- [ ] **Custom AI Models** (Bring your own model)
- [ ] **Plugins System** (Community extensions)
- [ ] **Offline Mode** (Local model support)
- [ ] **Team Features** (Shared context vaults)
- [ ] **Browser Extension** (Explain web content)
- [ ] **Spotlight Integration** (Quick explanations)
- [ ] **Siri Shortcuts** (Voice automation)

---

## 🐛 Troubleshooting

### Common Issues

#### "API Key Missing" Error

```bash
# Ensure .env file exists and contains keys
cat .env

# Should output:
OPENROUTER_API_KEY=sk-or-v1-...
GROQ_API_KEY=gsk_...
```

#### OCR Not Working

- Grant **Screen Recording** permission in System Preferences → Security & Privacy
- Restart the app after granting permissions

#### Voice Input Not Responding

- Grant **Microphone** and **Speech Recognition** permissions
- Check System Preferences → Security & Privacy → Privacy

#### Firebase Sync Fails

- Verify `GoogleService-Info.plist` is in the project
- Check Firestore rules allow user access
- Ensure user is authenticated

#### Hotkeys Not Working

- Check for conflicts with other apps (e.g., system shortcuts)
- Customize hotkeys in Settings → Shortcuts
- Grant **Accessibility** permission if needed

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 ClarifyThis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

---

## 🙏 Acknowledgments

- **OpenRouter** for providing access to cutting-edge AI models
- **Groq** for lightning-fast inference
- **Firebase** for reliable backend infrastructure
- **Apple** for excellent developer tools and frameworks
- The **open-source community** for inspiration and libraries

---

## 📬 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/manchikantithanush-netizen/ClarifyThis/issues)
- **Discussions**: [GitHub Discussions](https://github.com/manchikantithanush-netizen/ClarifyThis/discussions)
- **Email**: support@clarifythis.app
- **Website**: [clarifythisapp.netlify.app](https://clarifythisapp.netlify.app)

---

<div align="center">

**Made with ❤️ by the ClarifyThis Team**

[⬆ Back to Top](#-clarifythis)

</div>
