import Cocoa
import SwiftUI

class ErrorPanel: NSPanel {
    private static var activePanel: ErrorPanel?
    private var closeTimer: Timer?
    
    static func show(message: String) {
        DispatchQueue.main.async {
            if let existing = activePanel {
                existing.closeImmediate()
            }
            
            let panel = ErrorPanel(message: message)
            activePanel = panel
            panel.present()
        }
    }
    
    private init(message: String) {
        // Dimensions: Width + Padding for shadow
        let contentWidth: CGFloat = 300
        let contentHeight: CGFloat = 80 // Increased slightly to prevent clipping
        
        // --- SMART POSITIONING LOGIC ---
        
        let screen = NSScreen.main
        let screenFrame = screen?.visibleFrame ?? .zero
        
        // Fallback position (Ghost)
        let defaultExplainWidth: CGFloat = 480
        let defaultExplainHeight: CGFloat = 650
        // ExplainPanel logic is (maxX - width - 20)
        let defaultExplainX = screenFrame.maxX - defaultExplainWidth - 20
        // ExplainPanel logic is (minY + 80)
        let defaultExplainY = screenFrame.minY + 80
        
        var targetCenterX: CGFloat
        var targetCenterY: CGFloat
        
        // Check if ExplainPanel is actually open and valid
        if let existingExplain = ExplainPanel.shared,
           existingExplain.isVisible,
           existingExplain.windowNumber > 0 {
            
            // Use the REAL center of the open window
            targetCenterX = existingExplain.frame.midX
            targetCenterY = existingExplain.frame.midY
            
        } else {
            // Use the GHOST center
            targetCenterX = defaultExplainX + (defaultExplainWidth / 2)
            targetCenterY = defaultExplainY + (defaultExplainHeight / 2)
        }
        
        // Calculate Origin
        let errorX = targetCenterX - (contentWidth / 2)
        let errorY = targetCenterY - (contentHeight / 2)
        
        let panelRect = CGRect(x: errorX, y: errorY, width: contentWidth, height: contentHeight)
        
        // --- END POSITIONING LOGIC ---
        
        super.init(
            contentRect: panelRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        // Appearance Settings (The Fix for Black Lines)
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // IMPORTANT: Disable system shadow to prevent artifacts/black lines.
        // We render the shadow in SwiftUI instead.
        self.hasShadow = false
        
        self.level = .popUpMenu
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        
        // Setup SwiftUI
        let rootView = ErrorView(message: message)
        let hostingView = NSHostingView(rootView: rootView)
        
        // Ensure Hosting View is transparent
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.autoresizingMask = [.width, .height]
        
        self.contentView = hostingView
    }
    
    override var canBecomeKey: Bool { return false }
    
    private func present() {
        self.alphaValue = 0
        self.orderFrontRegardless()
        
        self.animator().alphaValue = 1.0
        
        closeTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    private func dismiss() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 0
        }, completionHandler: {
            self.closeImmediate()
        })
    }
    
    private func closeImmediate() {
        closeTimer?.invalidate()
        closeTimer = nil
        self.close()
        if ErrorPanel.activePanel === self {
            ErrorPanel.activePanel = nil
        }
    }
}
