import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    
    private var config: [String: String] = [:]
    
    private init() {
        loadConfig()
    }
    
    private func loadConfig() {
        // SECURITY: Load from environment variables or .env file
        // NEVER hardcode API keys in source code
        
        // Try loading from environment variables first
        var openRouterKey = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"] ?? ""
        var groqKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
        
        // If not in environment, try loading from .env file (for local development)
        if openRouterKey.isEmpty || groqKey.isEmpty {
            loadFromEnvFile()
            openRouterKey = config["OPENROUTER_API_KEY"] ?? ""
            groqKey = config["GROQ_API_KEY"] ?? ""
        }
        
        config = [
            "OPENROUTER_API_KEY": openRouterKey,
            "GROQ_API_KEY": groqKey
        ]
        
        // Log status without revealing keys
        if !openRouterKey.isEmpty {
            print("✅ OpenRouter API key loaded successfully")
        } else {
            print("⚠️ OpenRouter API key not found - set OPENROUTER_API_KEY environment variable")
        }
        
        if !groqKey.isEmpty {
            print("✅ Groq API key loaded successfully")
        } else {
            print("⚠️ Groq API key not found - set GROQ_API_KEY environment variable")
        }
    }
    
    private func loadFromEnvFile() {
        // Look for .env file in the project root and parent directories
        let fileManager = FileManager.default
        var searchPaths = [
            fileManager.currentDirectoryPath,
            Bundle.main.bundlePath,
            Bundle.main.resourcePath ?? "",
            URL(fileURLWithPath: fileManager.currentDirectoryPath).deletingLastPathComponent().path,
            URL(fileURLWithPath: fileManager.currentDirectoryPath).deletingLastPathComponent().deletingLastPathComponent().path
        ]
        
        for path in searchPaths {
            let envPath = URL(fileURLWithPath: path).appendingPathComponent(".env").path
            if fileManager.fileExists(atPath: envPath) {
                do {
                    let contents = try String(contentsOfFile: envPath, encoding: .utf8)
                    parseEnvFile(contents)
                    print("📄 Loaded configuration from .env file at: \(envPath)")
                    return
                } catch {
                    print("⚠️ Error reading .env file at \(envPath): \(error)")
                }
            }
        }
    }
    
    private func parseEnvFile(_ contents: String) {
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            
            let parts = trimmed.components(separatedBy: "=")
            if parts.count >= 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1...].joined(separator: "=")
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                config[key] = value
            }
        }
    }
    
    func getAPIKey(for provider: String) -> String {
        return config[provider] ?? ""
    }
    
    var openRouterAPIKey: String {
        return getAPIKey(for: "OPENROUTER_API_KEY")
    }
    
    var groqAPIKey: String {
        return getAPIKey(for: "GROQ_API_KEY")
    }
}
