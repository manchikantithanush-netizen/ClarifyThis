import Cocoa
import ScreenCaptureKit

class Screenshotter {
    static func capture(rect: CGRect, completion: @escaping (CGImage?) -> Void) {
        Task {
            do {
                let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                
                guard let display = availableContent.displays.first else {
                    print("❌ No display found")
                    completion(nil)
                    return
                }
                
                let filter = SCContentFilter(display: display, excludingWindows: [])
                
                let config = SCStreamConfiguration()
                config.sourceRect = rect
                config.width = Int(rect.width)
                config.height = Int(rect.height)
                config.scalesToFit = false
                
                let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
                
                completion(image)
                
            } catch {
                print("❌ Screenshot capture failed: \(error)")
                print("⚠️  Likely missing Screen Recording permission.")
                print("📍 Go to: System Settings → Privacy & Security → Screen Recording")
                print("📍 Enable permission for ClarifyThisv2")
                completion(nil)
            }
        }
    }
    
    static func cgImageToNSImage(_ cgImage: CGImage) -> NSImage {
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        let nsImage = NSImage(size: size)
        nsImage.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
        return nsImage
    }
}
