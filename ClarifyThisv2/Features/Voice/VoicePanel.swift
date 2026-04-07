import Cocoa
import SwiftUI

class VoicePanel: NSPanel {
    let viewModel = VoiceViewModel()
    
    init() {
        // Voice Panel Dimensions
        let panelWidth: CGFloat = 320
        let panelHeight: CGFloat = 180
        
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        
        // --- SMART POSITIONING LOGIC ---
        
        // 1. Define where the Explain Panel usually sits (Default fallback)
        let defaultExplainWidth: CGFloat = 480
        let defaultExplainHeight: CGFloat = 650
        let defaultExplainX = screenFrame.maxX - defaultExplainWidth - 20
        let defaultExplainY = screenFrame.minY + 80
        
        var targetCenterX: CGFloat
        var targetCenterY: CGFloat
        
        // 2. Check if ExplainPanel is currently open
        if let existingExplain = ExplainPanel.shared, existingExplain.isVisible {
            // Use the REAL center of the open window (handles dragging/resizing)
            targetCenterX = existingExplain.frame.midX
            targetCenterY = existingExplain.frame.midY
        } else {
            // Use the "Ghost" center of where it normally spawns
            targetCenterX = defaultExplainX + (defaultExplainWidth / 2)
            targetCenterY = defaultExplainY + (defaultExplainHeight / 2)
        }
        
        // 3. Calculate origin for Voice Panel to be perfectly centered
        let voiceX = targetCenterX - (panelWidth / 2)
        let voiceY = targetCenterY - (panelHeight / 2)
        
        let panelRect = CGRect(x: voiceX, y: voiceY, width: panelWidth, height: panelHeight)
        
        // --- END POSITIONING LOGIC ---
        
        super.init(
            contentRect: panelRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // Critical: .popUpMenu ensures it sits ON TOP of the Explain Panel
        self.level = .popUpMenu
        
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        
        let rootView = VoiceView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.autoresizingMask = [.width, .height]
        self.contentView = hostingView
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    func show() {
        self.orderFrontRegardless()
    }
    
    func finishRecording() {
        if viewModel.isRecording {
            viewModel.stopSession()
        }
    }
}
