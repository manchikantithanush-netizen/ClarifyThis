import Cocoa

class MarkdownFormatter {
    static func formatMarkdown(_ markdown: String) -> NSAttributedString {
        var processedText = markdown
        
        processedText = processedText.replacingOccurrences(of: "**", with: "")
        processedText = processedText.replacingOccurrences(of: "`", with: "")
        processedText = processedText.replacingOccurrences(of: "###", with: "")
        processedText = processedText.replacingOccurrences(of: "##", with: "")
        processedText = processedText.replacingOccurrences(of: "#", with: "")
        
        let attributedString = NSMutableAttributedString(string: processedText)
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        let baseFont = NSFont.systemFont(ofSize: 14)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 8
        
        attributedString.addAttribute(.font, value: baseFont, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: NSColor.white, range: fullRange)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        applyBoldFormatting(to: attributedString, in: markdown)
        applyCodeFormatting(to: attributedString, in: markdown)
        applyNumberedListFormatting(to: attributedString)
        
        return attributedString
    }
    
    private static func applyBoldFormatting(to attributedString: NSMutableAttributedString, in original: String) {
        let text = attributedString.string
        var searchRange = text.startIndex..<text.endIndex
        
        while let range = original.range(of: "\\*\\*([^*]+)\\*\\*", options: .regularExpression, range: searchRange) {
            let content = String(original[range]).replacingOccurrences(of: "**", with: "")
            
            if let targetRange = text.range(of: content, options: [], range: searchRange) {
                let nsRange = NSRange(targetRange, in: text)
                
                let boldFont = NSFont.boldSystemFont(ofSize: 14)
                attributedString.addAttribute(.font, value: boldFont, range: nsRange)
                attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue.withAlphaComponent(0.9), range: nsRange)
                
                searchRange = targetRange.upperBound..<text.endIndex
            } else {
                break
            }
        }
    }
    
    private static func applyCodeFormatting(to attributedString: NSMutableAttributedString, in original: String) {
        let text = attributedString.string
        var searchRange = text.startIndex..<text.endIndex
        
        while let range = original.range(of: "`([^`]+)`", options: .regularExpression, range: searchRange) {
            let content = String(original[range]).replacingOccurrences(of: "`", with: "")
            
            if let targetRange = text.range(of: content, options: [], range: searchRange) {
                let nsRange = NSRange(targetRange, in: text)
                
                let codeFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
                attributedString.addAttribute(.font, value: codeFont, range: nsRange)
                attributedString.addAttribute(.foregroundColor, value: NSColor.systemPink.withAlphaComponent(0.9), range: nsRange)
                attributedString.addAttribute(.backgroundColor, value: NSColor.white.withAlphaComponent(0.1), range: nsRange)
                
                searchRange = targetRange.upperBound..<text.endIndex
            } else {
                break
            }
        }
    }
    
    private static func applyNumberedListFormatting(to attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let lines = text.components(separatedBy: .newlines)
        var currentPosition = 0
        
        for line in lines {
            let lineLength = line.utf16.count
            
            if line.range(of: "^\\d+\\.", options: .regularExpression) != nil {
                let nsRange = NSRange(location: currentPosition, length: lineLength)
                attributedString.addAttribute(.foregroundColor, value: NSColor.systemCyan.withAlphaComponent(0.9), range: nsRange)
            }
            
            currentPosition += lineLength + 1
        }
    }
}
