import SwiftUI
import WebKit

struct RichTextRenderer: NSViewRepresentable {
    let markdown: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Enabling developer extras allows you to inspect the webview in Safari (optional)
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        // Make WebView Transparent
        webView.setValue(false, forKey: "drawsBackground")
        webView.enabler = false
        
        webView.loadHTMLString(htmlTemplate, baseURL: nil)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        if let data = markdown.data(using: .utf8) {
            let base64 = data.base64EncodedString()
            if !context.coordinator.isPageLoaded {
                context.coordinator.pendingContent = base64
            } else {
                let js = "updateContentFromBase64('\(base64)');"
                webView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: RichTextRenderer
        var isPageLoaded = false
        var pendingContent: String?
        
        init(_ parent: RichTextRenderer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isPageLoaded = true
            if let content = pendingContent {
                let js = "updateContentFromBase64('\(content)');"
                webView.evaluateJavaScript(js, completionHandler: nil)
                pendingContent = nil
            }
        }
    }
    
    // MARK: - HTML Template
    private var htmlTemplate: String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            
            <!-- MARKDOWN & SYNTAX -->
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/atom-one-dark.min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js"></script>
            
            <!-- KATEX (MATH) -->
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>
            <!-- MHCHEM (CHEMISTRY SUPPORT) -->
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/mhchem.min.js"></script>
            
            <style>
                body {
                    background-color: transparent;
                    color: #e5e7eb;
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    font-size: 14px;
                    line-height: 1.6;
                    margin: 0;
                    padding: 15px;
                    -webkit-font-smoothing: antialiased;
                    box-sizing: border-box;
                }
                
                /* Elements */
                p { margin-bottom: 12px; }
                strong { color: #fff; font-weight: 600; }
                ul, ol { padding-left: 20px; margin-bottom: 12px; }
                li { margin-bottom: 6px; }
                
                /* Code */
                pre {
                    background: #1e1e1e;
                    padding: 12px;
                    border-radius: 8px;
                    border: 1px solid #333;
                    overflow-x: auto;
                    font-family: "Menlo", monospace;
                    margin: 10px 0;
                }
                code { font-family: "Menlo", monospace; font-size: 13px; }
                :not(pre) > code {
                    background: rgba(255,255,255,0.15);
                    padding: 2px 6px;
                    border-radius: 4px;
                    color: #ff79c6;
                    font-size: 0.9em;
                }
                
                /* Tables */
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin: 15px 0;
                    background: #161b22;
                    border-radius: 8px;
                    overflow: hidden;
                    font-size: 13px;
                }
                th { background: #21262d; color: #fff; font-weight: 600; padding: 10px; text-align: left; border-bottom: 1px solid #30363d; }
                td { padding: 10px; border-bottom: 1px solid #30363d; color: #c9d1d9; }
                tr:last-child td { border-bottom: none; }
                
                /* Headers */
                h1, h2, h3 { color: #fff; margin-top: 20px; margin-bottom: 10px; font-weight: 600; }
                h1 { border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 8px; }
                
                /* Math Fixes */
                .katex-display { overflow-x: auto; overflow-y: hidden; padding: 5px 0; }
            </style>
        </head>
        <body>
            <div id="content"></div>
            
            <script>
                function updateContentFromBase64(base64) {
                    try {
                        const rawMarkdown = decodeURIComponent(escape(window.atob(base64)));
                        
                        // 1. Parse Markdown
                        const html = marked.parse(rawMarkdown);
                        const contentDiv = document.getElementById('content');
                        contentDiv.innerHTML = html;
                        
                        // 2. Highlight Code
                        hljs.highlightAll();
                        
                        // 3. Render Math & Chemistry
                        renderMathInElement(contentDiv, {
                            delimiters: [
                                {left: '$$', right: '$$', display: true},
                                {left: '$', right: '$', display: false},
                                {left: '\\\\[', right: '\\\\]', display: true},
                                {left: '\\\\(', right: '\\\\)', display: false}
                            ],
                            throwOnError : false,
                            errorColor: '#cc0000',
                            trust: true // Required for mhchem
                        });
                        
                        // 4. Scroll
                        window.scrollTo(0, document.body.scrollHeight);
                        
                    } catch(e) {
                        console.error(e);
                    }
                }
            </script>
        </body>
        </html>
        """
    }
}

extension WKWebView {
    var enabler: Bool {
        get { return false }
        set { self.setValue(newValue, forKey: "drawsBackground") }
    }
}
