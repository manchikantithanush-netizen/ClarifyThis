import Cocoa

class VoiceVisualizer: NSView {
    private var barLayers: [CAShapeLayer] = []
    private let numberOfBars = 40
    private var audioLevel: Float = 0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupBars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBars() {
        self.wantsLayer = true
        
        let barWidth: CGFloat = 3
        let spacing: CGFloat = 2
        let totalWidth = CGFloat(numberOfBars) * (barWidth + spacing)
        let startX = (bounds.width - totalWidth) / 2
        
        for i in 0..<numberOfBars {
            let barLayer = CAShapeLayer()
            let xPosition = startX + CGFloat(i) * (barWidth + spacing)
            
            barLayer.frame = CGRect(x: xPosition, y: bounds.midY, width: barWidth, height: 0)
            barLayer.backgroundColor = colorForBar(at: i).cgColor
            barLayer.cornerRadius = barWidth / 2
            
            self.layer?.addSublayer(barLayer)
            barLayers.append(barLayer)
        }
    }
    
    private func colorForBar(at index: Int) -> NSColor {
        let progress = Float(index) / Float(numberOfBars)
        
        // Gradient colors matching your app theme
        let colors: [(r: CGFloat, g: CGFloat, b: CGFloat)] = [
            (1.0, 0.4, 0.5),   // Pink
            (0.9, 0.5, 0.9),   // Purple
            (0.5, 0.6, 1.0),   // Blue
            (0.4, 0.9, 0.9),   // Cyan
            (0.5, 1.0, 0.6),   // Green
        ]
        
        let colorIndex = Int(progress * Float(colors.count - 1))
        let nextColorIndex = min(colorIndex + 1, colors.count - 1)
        let localProgress = CGFloat((progress * Float(colors.count - 1)).truncatingRemainder(dividingBy: 1))
        
        let color1 = colors[colorIndex]
        let color2 = colors[nextColorIndex]
        
        let r = color1.r + (color2.r - color1.r) * localProgress
        let g = color1.g + (color2.g - color1.g) * localProgress
        let b = color1.b + (color2.b - color1.b) * localProgress
        
        return NSColor(red: r, green: g, blue: b, alpha: 0.9)
    }
    
    func updateAudioLevel(_ level: Float) {
        audioLevel = level
        animateBars()
    }
    
    private func animateBars() {
        let maxHeight: CGFloat = 80
        
        for (index, barLayer) in barLayers.enumerated() {
            // Create wave effect - bars in center are taller
            let distanceFromCenter = abs(Float(index) - Float(numberOfBars) / 2.0)
            let centerEffect = 1.0 - (distanceFromCenter / (Float(numberOfBars) / 2.0))
            
            // Add some randomness for natural feel
            let randomFactor = Float.random(in: 0.7...1.0)
            
            let height = CGFloat(audioLevel * centerEffect * randomFactor) * maxHeight
            let clampedHeight = max(4, height) // Minimum height
            
            CATransaction.begin()
            CATransaction.setDisableActions(false)
            CATransaction.setAnimationDuration(0.1)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            
            barLayer.frame = CGRect(
                x: barLayer.frame.origin.x,
                y: bounds.midY - clampedHeight / 2,
                width: barLayer.frame.width,
                height: clampedHeight
            )
            
            CATransaction.commit()
        }
    }
    
    func reset() {
        for barLayer in barLayers {
            barLayer.frame = CGRect(
                x: barLayer.frame.origin.x,
                y: bounds.midY,
                width: barLayer.frame.width,
                height: 4
            )
        }
    }
}
