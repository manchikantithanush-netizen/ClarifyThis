import SwiftUI
import Cocoa

// MARK: - 1. Frosted Glass Effect
struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow // Dark translucent style
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// MARK: - 2. Google Icon
struct GoogleIconView: View {
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let cx = w / 2
            let cy = h / 2
            
            ZStack {
                // Blue
                Path { path in
                    path.move(to: CGPoint(x: cx, y: cy))
                    path.addArc(center: CGPoint(x: cx, y: cy), radius: w/2, startAngle: .degrees(-45), endAngle: .degrees(45), clockwise: false)
                    path.closeSubpath()
                }.fill(Color(NSColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1)))
                
                // Green
                Path { path in
                    path.move(to: CGPoint(x: cx, y: cy))
                    path.addArc(center: CGPoint(x: cx, y: cy), radius: w/2, startAngle: .degrees(45), endAngle: .degrees(135), clockwise: false)
                    path.closeSubpath()
                }.fill(Color(NSColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)))
                
                // Yellow
                Path { path in
                    path.move(to: CGPoint(x: cx, y: cy))
                    path.addArc(center: CGPoint(x: cx, y: cy), radius: w/2, startAngle: .degrees(135), endAngle: .degrees(225), clockwise: false)
                    path.closeSubpath()
                }.fill(Color(NSColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)))
                
                // Red
                Path { path in
                    path.move(to: CGPoint(x: cx, y: cy))
                    path.addArc(center: CGPoint(x: cx, y: cy), radius: w/2, startAngle: .degrees(225), endAngle: .degrees(315), clockwise: false)
                    path.closeSubpath()
                }.fill(Color(NSColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)))
                
                // White Center
                Circle()
                    .fill(Color.white)
                    .frame(width: w * 0.65, height: h * 0.65)
                
                // Blue Bar
                Rectangle()
                    .fill(Color(NSColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1)))
                    .frame(width: w * 0.45, height: h * 0.18)
                    .offset(x: w * 0.2, y: 0)
            }
        }
    }
}
