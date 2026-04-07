# Contributing to ClarifyThis

First off, thank you for considering contributing to ClarifyThis! It's people like you that make ClarifyThis such a great tool.

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots and animated GIFs** if possible
* **Include your environment details** (macOS version, ClarifyThis version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior** and **explain which behavior you expected to see instead**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Follow the Swift style guide
* Include thoughtful comments in your code
* Write unit tests for new features
* End all files with a newline
* Avoid platform-dependent code

## 💻 Development Process

### Setup Your Development Environment

1. **Fork the Repository**
   ```bash
   # Fork via GitHub UI, then clone your fork
   git clone https://github.com/YOUR-USERNAME/ClarifyThis.git
   cd ClarifyThis
   ```

2. **Set Up Environment**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Add your API keys to .env
   nano .env
   ```

3. **Open in Xcode**
   ```bash
   open ClarifyThisv2.xcodeproj
   ```

4. **Create a Branch**
   ```bash
   git checkout -b feature/my-new-feature
   # or
   git checkout -b fix/issue-123
   ```

### Making Changes

1. **Write Clear Code**
   - Follow Swift API Design Guidelines
   - Use meaningful variable and function names
   - Add comments for complex logic
   - Keep functions small and focused

2. **Test Your Changes**
   - Test on multiple macOS versions if possible
   - Test both light and dark modes
   - Test with different AI providers
   - Ensure no regressions

3. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: Add amazing new feature"
   ```
   
   Use conventional commits:
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `style:` Code style changes (formatting, etc.)
   - `refactor:` Code refactoring
   - `test:` Adding tests
   - `chore:` Maintenance tasks

4. **Push to Your Fork**
   ```bash
   git push origin feature/my-new-feature
   ```

5. **Create Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template
   - Link any related issues

## 🎨 Code Style

### Swift Style Guidelines

```swift
// ✅ Good
func calculateTotalPrice(items: [Item], discount: Double) -> Double {
    let subtotal = items.reduce(0) { $0 + $1.price }
    return subtotal * (1 - discount)
}

// ❌ Bad
func calc(i: [Item], d: Double) -> Double {
    var t = 0.0
    for item in i { t += item.price }
    return t * (1 - d)
}
```

### Key Principles

1. **Clarity at the point of use** is your most important goal
2. **Prefer methods and properties** to free functions
3. **Use type inference** where it improves readability
4. **Avoid abbreviations** in names
5. **Include all needed words** while omitting needless words
6. **Name variables and parameters** according to their roles

### SwiftUI Guidelines

```swift
// ✅ Good - Clear structure
struct SettingsView: View {
    @State private var isEnabled = false
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            toggleSection
        }
        .padding()
    }
    
    private var headerSection: some View {
        Text("Settings")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
    
    private var toggleSection: some View {
        Toggle("Enable Feature", isOn: $isEnabled)
    }
}

// ❌ Bad - Everything in body
struct SettingsView: View {
    @State private var isEnabled = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings").font(.largeTitle).fontWeight(.bold)
            Toggle("Enable Feature", isOn: $isEnabled)
        }.padding()
    }
}
```

## 🧪 Testing

### Manual Testing Checklist

Before submitting a PR, ensure:

- [ ] App launches without crashes
- [ ] Hotkeys work correctly
- [ ] Screenshot capture and OCR function properly
- [ ] Voice input records and transcribes
- [ ] AI responses render correctly (text, LaTeX, graphs)
- [ ] Context vault saves and loads
- [ ] Settings persist between launches
- [ ] Dark/Light mode both work
- [ ] No sensitive data logged to console
- [ ] Firebase sync works (if applicable)

### Unit Testing

```swift
// Example test structure
import XCTest
@testable import ClarifyThisv2

final class ConfigManagerTests: XCTestCase {
    func testAPIKeyLoading() {
        // Given
        setenv("OPENROUTER_API_KEY", "test-key", 1)
        
        // When
        let config = ConfigManager()
        
        // Then
        XCTAssertEqual(config.openRouterAPIKey, "test-key")
    }
}
```

## 📝 Documentation

### Code Documentation

Use DocC-style comments for public APIs:

```swift
/// Encrypts the given text using AES-GCM encryption.
///
/// - Parameters:
///   - text: The plaintext string to encrypt
///   - userId: The user ID for key derivation
/// - Returns: The encrypted string in Base64 format, or nil if encryption fails
///
/// - Important: The userId must be non-empty
/// - Note: Uses AES-256-GCM with a 96-bit nonce
func encrypt(_ text: String, for userId: String) -> String? {
    // Implementation
}
```

### README Updates

If your change affects user-facing features:
1. Update the README.md
2. Add to the Features section if applicable
3. Update installation/usage instructions if needed
4. Add troubleshooting notes for common issues

## 🔒 Security

### Security-Sensitive Changes

If your contribution involves:
- Authentication/Authorization
- Encryption/Decryption
- API key handling
- Network requests
- File system access

**Please:**
1. Mention it explicitly in your PR
2. Follow security best practices
3. Never commit secrets or API keys
4. Test thoroughly for security vulnerabilities
5. Consider potential attack vectors

### Reporting Security Vulnerabilities

**DO NOT** create a public issue for security vulnerabilities.

Instead:
1. Email security@clarifythis.app
2. Include detailed steps to reproduce
3. Allow time for a fix before public disclosure

## 📋 Pull Request Checklist

Before submitting your PR, verify:

- [ ] Code follows the style guidelines
- [ ] Self-review of code completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings introduced
- [ ] Manual testing completed
- [ ] Commit messages are clear
- [ ] PR description explains the changes
- [ ] Related issues are linked
- [ ] Screenshots included (for UI changes)

## 🎯 What Should I Work On?

Not sure where to start? Look for issues labeled:

- `good first issue` - Great for newcomers
- `help wanted` - We need your expertise!
- `bug` - Something isn't working
- `enhancement` - New feature requests
- `documentation` - Improve docs

## 💬 Questions?

Feel free to:
- Open a discussion on GitHub
- Comment on existing issues
- Reach out via email

## 🙏 Thank You!

Your contributions make ClarifyThis better for everyone. We appreciate your time and effort!

---

*This contributing guide is adapted from the open-source community's best practices.*
