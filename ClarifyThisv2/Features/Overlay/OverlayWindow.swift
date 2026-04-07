import Cocoa
import SwiftUI

// MARK: - 1. Mouse Handler
class OverlayMouseHandler: NSView {
    var state: OverlayState
    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?
    
    init(frame frameRect: NSRect, state: OverlayState) {
        self.state = state
        super.init(frame: frameRect)
        
        let trackingArea = NSTrackingArea(
            rect: frameRect,
            options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        self.addTrackingArea(trackingArea)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // Top-Left coordinate system for drawing
    override var isFlipped: Bool { return true }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        state.isDragging = true
        updateSelectionRect()
    }
    
    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        updateSelectionRect()
    }
    
    override func mouseUp(with event: NSEvent) {
        state.isDragging = false
        
        guard let start = startPoint, let end = currentPoint else {
            cancelSelection()
            return
        }
        
        // Ignore tiny clicks
        if hypot(end.x - start.x, end.y - start.y) < 5.0 {
            cancelSelection()
            return
        }
        
        // 1. Get the visual rect (Top-Left coords, relative to this specific window)
        let visualRect = getNormalizedRect()
        
        // 2. Convert to Global Screen Coordinates (Top-Left origin)
        // This fixes the inversion bug
        let screenRect = convertToScreenCoordinates(visualRect)
        
        // Hide visually immediately
        state.selectionRect = .zero
        OverlayController.shared.hide()
        
        // Process
        processCapture(screenRect: screenRect)
        
        startPoint = nil
        currentPoint = nil
    }
    
    private func updateSelectionRect() {
        state.selectionRect = getNormalizedRect()
    }
    
    private func cancelSelection() {
        startPoint = nil
        currentPoint = nil
        state.selectionRect = .zero
        OverlayController.shared.hide()
    }
    
    private func getNormalizedRect() -> CGRect {
        guard let start = startPoint, let current = currentPoint else { return .zero }
        
        // Normalize coordinates so width/height are always positive
        // and x,y is always the top-left corner of the selection
        let x = min(start.x, current.x)
        let y = min(start.y, current.y)
        let width = abs(current.x - start.x)
        let height = abs(current.y - start.y)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func convertToScreenCoordinates(_ rect: CGRect) -> CGRect {
        guard let window = self.window else { return rect }
        
        // --- FIX STARTS HERE ---
        
        // 1. Get the Primary Screen height.
        // CoreGraphics (Screenshotter) sets (0,0) at the Top-Left of the Primary Screen.
        // AppKit sets (0,0) at the Bottom-Left of the Primary Screen.
        guard let primaryScreen = NSScreen.screens.first else { return rect }
        let primaryHeight = primaryScreen.frame.height
        
        // 2. Calculate Global X
        // Window.frame.minX is the global X position of this window.
        // rect.minX is the selection's offset inside this window.
        let globalX = window.frame.minX + rect.minX
        
        // 3. Calculate Global Y (Top-Left based)
        // AppKit Y (Bottom-Left based) = window.frame.maxY
        // This gives us the top edge of the window in AppKit coordinates.
        // To get the CoreGraphics "Y from Top" value of the window's top edge:
        // CG_WindowTop = PrimaryHeight - AppKit_WindowTop
        let windowTopFromScreenTop = primaryHeight - window.frame.maxY
        
        // Now add the selection's offset (rect.minY is already top-down because isFlipped = true)
        let globalY = windowTopFromScreenTop + rect.minY
        
        return CGRect(x: globalX, y: globalY, width: rect.width, height: rect.height)
        
        // --- FIX ENDS HERE ---
    }
    
    private func processCapture(screenRect: CGRect) {
        Screenshotter.capture(rect: screenRect) { cgImage in
            guard let cgImage = cgImage else { return }
            
            DispatchQueue.main.async {
                let nsImage = Screenshotter.cgImageToNSImage(cgImage)
                let preview = PreviewPanel(image: nsImage, nearRect: screenRect)
                preview.show()
            }
            
            OCR.recognizeText(from: cgImage) { text in
                DispatchQueue.main.async {
                    let frontmostApp = NSWorkspace.shared.frontmostApplication
                    
                    if text.isEmpty {
                        ErrorPanel.show(message: "No text detected")
                    } else {
                        ExplainPanel.showExplanation(for: text)
                    }
                    
                    // Return focus
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        if let app = frontmostApp, app.bundleIdentifier != Bundle.main.bundleIdentifier {
                            app.activate(options: [])
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 2. Window
class OverlayWindow: NSPanel {
    init(screen: NSScreen) {
        let state = OverlayState()
        state.isActive = true
        
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.level = .popUpMenu
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        self.isFloatingPanel = true
        self.becomesKeyOnlyIfNeeded = true
        
        // Logic Layer
        let mouseHandler = OverlayMouseHandler(frame: screen.frame, state: state)
        
        // Visual Layer
        let visuals = OverlayVisualsView(state: state)
        let hostingView = NSHostingView(rootView: visuals)
        
        // Ensure hosting view fills the mouse handler area
        hostingView.frame = NSRect(origin: .zero, size: screen.frame.size)
        hostingView.autoresizingMask = [.width, .height]
        
        // Add visuals BEHIND mouse logic
        mouseHandler.addSubview(hostingView, positioned: .below, relativeTo: nil)
        
        self.contentView = mouseHandler
    }
    
    override var canBecomeKey: Bool { return false }
    override var canBecomeMain: Bool { return false }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC
            OverlayController.shared.hide()
        } else {
            super.keyDown(with: event)
        }
    }
}

// MARK: - 3. Controller
class OverlayController {
    static let shared = OverlayController()
    private var overlayWindow: OverlayWindow?
    
    private init() {}
    
    func show() {
        guard overlayWindow == nil else { return }
        
        // Ensure we capture the screen where the mouse currently is
        let mouseLoc = NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) ?? NSScreen.main!
        
        let window = OverlayWindow(screen: screen)
        overlayWindow = window
        window.orderFrontRegardless()
    }
    
    func hide() {
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
    }
}
