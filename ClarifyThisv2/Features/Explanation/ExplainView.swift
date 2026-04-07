import SwiftUI

struct ExplainView: View {
    @ObservedObject var viewModel: ExplainViewModel
    @ObservedObject var windowState: PanelWindowState
    
    var onClose: () -> Void
    var onNewWindow: () -> Void
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            if windowState.isMinimized {
                // MARK: - Minimized State
                Button(action: { windowState.setExpanded(true) }) {
                    ZStack {
                        Circle()
                            .fill(.black.opacity(0.85))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                        
                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                        Text("C")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
                .padding(15)
                .transition(.opacity)
                
            } else {
                // MARK: - Expanded State
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black.opacity(0.85))
                        .background(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Clarify")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 10) {
                                Button(action: onNewWindow) {
                                    Image(systemName: "plus.rectangle.on.rectangle")
                                }
                                .buttonStyle(IconButtonStyle())
                                
                                Button(action: onClose) {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(IconButtonStyle())
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.2)) // Header background
                        
                        // --- Main Text Area ---
                        // GeometryReader ensures WebView fills space without collapsing
                        GeometryReader { geo in
                            RichTextRenderer(markdown: viewModel.markdownContent)
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .frame(minHeight: 100, maxHeight: .infinity)
                        .padding(.horizontal, 4)
                        
                        // Controls & Input
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Button("Copy") { viewModel.copyToClipboard() }
                                    .buttonStyle(GlassButtonStyle())
                                    .disabled(viewModel.markdownContent.isEmpty)
                                
                                Button("Simplify") { viewModel.simplifyExplanation() }
                                    .buttonStyle(GlassButtonStyle())
                                    .disabled(viewModel.markdownContent.isEmpty || viewModel.isLoading)
                                
                                Spacer()
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .controlSize(.small)
                                        .colorScheme(.dark)
                                }
                            }
                            
                            HStack(alignment: .bottom) {
                                TextField("Ask follow up...", text: $viewModel.inputText, axis: .vertical)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(.white)
                                    .focused($isInputFocused)
                                    .onSubmit { viewModel.sendUserMessage() }
                                    .padding(8)
                                
                                Button(action: viewModel.sendUserMessage) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, 4)
                                .padding(.bottom, 4)
                            }
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.2)) // Footer background
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .transition(.scale(scale: 0.1, anchor: .topTrailing).combined(with: .opacity))
                .onAppear {
                    // Only auto-focus if this is a NEW session (empty history)
                    if viewModel.chatHistory.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isInputFocused = true
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: windowState.isMinimized)
    }
}

// MARK: - Styles

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white.opacity(0.7))
            .padding(6)
            .background(Color.white.opacity(configuration.isPressed ? 0.2 : 0.05))
            .clipShape(Circle())
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(configuration.isPressed ? 0.25 : 0.15))
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
