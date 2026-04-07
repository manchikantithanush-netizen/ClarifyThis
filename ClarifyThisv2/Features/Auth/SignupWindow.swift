import Cocoa
import SwiftUI

// MARK: - Signup View
struct SignupView: View {
    var onSignupSuccess: () -> Void
    var onNavigateToLogin: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    
    private let inputBg = Color.black.opacity(0.3)
    private let inputStroke = Color.white.opacity(0.15)
    
    var body: some View {
        ZStack {
            VisualEffect().edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 12) {
                    if let nsImage = NSImage(named: "AppIcon") {
                        Image(nsImage: nsImage)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    } else {
                        Text("✨").font(.system(size: 50))
                    }
                    
                    VStack(spacing: 4) {
                        Text("Create Account").font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                        Text("Join us to get started").font(.system(size: 14)).foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.top, 35)
                
                // Google Button
                Button(action: handleGoogleSignup) {
                    HStack(spacing: 12) {
                        GoogleIconView().frame(width: 18, height: 18)
                        Text("Sign up with Google").font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 40)
                
                // Inputs
                VStack(spacing: 14) {
                    TextField("Email Address", text: $email)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(14)
                        .background(inputBg)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(inputStroke, lineWidth: 1))
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    SecureField("Password (min 6 chars)", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(14)
                        .background(inputBg)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(inputStroke, lineWidth: 1))
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(14)
                        .background(inputBg)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(inputStroke, lineWidth: 1))
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 40)
                
                // Error
                if showError, let msg = errorMessage {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(NSColor.systemRed))
                        Text(msg).font(.system(size: 13, weight: .medium)).foregroundColor(Color(NSColor.systemRed))
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(NSColor.systemRed).opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                }
                
                // Signup Action
                Button(action: handleSignup) {
                    ZStack {
                        if isLoading { ProgressView().scaleEffect(0.7) }
                        else { Text("Create Account").font(.system(size: 15, weight: .semibold)) }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(NSColor.systemBlue))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 40)
                .disabled(isLoading)
                
                Spacer()
                
                HStack {
                    Text("Already have an account?").foregroundColor(.white.opacity(0.6))
                    Button("Sign In") { onNavigateToLogin() }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(Color(NSColor.systemBlue))
                }
                .padding(.bottom, 30)
            }
        }
        .frame(width: 400, height: 650)
    }
    
    private func handleSignup() {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        guard !cleanEmail.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else { return triggerError("Fill all fields") }
        guard password.count >= 6 else { return triggerError("Password min 6 chars") }
        guard password == confirmPassword else { return triggerError("Passwords don't match") }
        
        isLoading = true
        FirebaseManager.shared.signUp(email: cleanEmail, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success: onSignupSuccess()
                case .failure(let err): triggerError(err.localizedDescription)
                }
            }
        }
    }
    
    private func handleGoogleSignup() {
        isLoading = true
        let window = NSApp.keyWindow ?? NSWindow()
        FirebaseManager.shared.signInWithGoogle(presentingWindow: window) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success: onSignupSuccess()
                case .failure(let err): triggerError(err.localizedDescription)
                }
            }
        }
    }
    
    private func triggerError(_ msg: String) {
        errorMessage = msg
        withAnimation { showError = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { withAnimation { showError = false } }
    }
}

// MARK: - Signup Window Controller
class SignupWindow: NSWindow {
    init() {
        let w: CGFloat = 400
        let h: CGFloat = 650
        let screen = NSScreen.main?.visibleFrame ?? .zero
        let rect = CGRect(x: screen.midX - w/2, y: screen.midY - h/2, width: w, height: h)
        
        super.init(contentRect: rect, styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
        self.hasShadow = true
        
        let rootView = SignupView(
            onSignupSuccess: { [weak self] in self?.close(); HomeWindowController.shared.show() },
            onNavigateToLogin: { [weak self] in self?.close(); LoginWindow().makeKeyAndOrderFront(nil) }
        )
        
        let hosting = NSHostingView(rootView: rootView)
        hosting.wantsLayer = true
        hosting.layer?.backgroundColor = NSColor.clear.cgColor
        hosting.layer?.cornerRadius = 20
        hosting.layer?.masksToBounds = true
        
        self.contentView = hosting
        self.center()
    }
}
