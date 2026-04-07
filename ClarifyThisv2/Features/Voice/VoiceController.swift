import Cocoa

class VoiceController {
    static let shared = VoiceController()
    
    private var voicePanel: VoicePanel?
    
    private init() {}
    
    // MARK: - Public API
    
    // Fixes the error in StatusBarController
    func show() {
        // Acts as a Toggle for manual clicks (Menu Bar)
        if voicePanel == nil {
            startSession()
        } else {
            stopSession()
        }
    }
    
    // MARK: - Actions
    
    func startSession() {
        // Only start if not already existing
        if voicePanel == nil {
            let panel = VoicePanel()
            voicePanel = panel
            panel.show()
        }
    }
    
    func stopSession() {
        // Stop recording and process text
        voicePanel?.finishRecording()
    }
    
    func cancelSession() {
        // Just close without processing (e.g. for Ctrl+C)
        hide()
    }
    
    // MARK: - Internal
    
    func hide() {
        voicePanel?.close()
        voicePanel = nil
    }
    
    func reset() {
        hide()
    }
}
