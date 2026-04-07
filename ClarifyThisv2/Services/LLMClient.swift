import Foundation

// Make these accessible to ExplainPanel
enum ExplainMode {
    case normal
    case simpler
}

struct Message {
    let role: String // "system", "user", "assistant"
    let content: String
}

protocol LLMClient {
    func explain(text: String, mode: ExplainMode, completion: @escaping (Result<String, Error>) -> Void)
    func chat(messages: [Message], completion: @escaping (Result<String, Error>) -> Void)
}

enum LLMError: Error {
    case missingAPIKey
    case invalidResponse
    case networkError(String)
}

class GroqClient: LLMClient {
    private let apiKey: String?
    private let endpoint = "https://api.groq.com/openai/v1/chat/completions"
    private let model = "llama-3.1-8b-instant"
    
    init() {
        self.apiKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"]
    }
    
    func explain(text: String, mode: ExplainMode, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            completion(.failure(LLMError.missingAPIKey))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let systemPrompt = "You are a fast, clear tutor. Explain the text simply. If it is a concept, define it and give one example. If it's an error message or code, explain what it means and provide 2–3 fixes. Keep it short."
            
            var userMessage = text
            if mode == .simpler {
                userMessage += "\n\nUse even simpler words and shorter sentences."
            }
            
            let payload: [String: Any] = [
                "model": self.model,
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": userMessage]
                ],
                "temperature": 0.7,
                "max_tokens": 500
            ]
            
            self.makeRequest(payload: payload, completion: completion)
        }
    }
    
    func chat(messages: [Message], completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            completion(.failure(LLMError.missingAPIKey))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let messagePayload = messages.map { msg in
                ["role": msg.role, "content": msg.content]
            }
            
            let payload: [String: Any] = [
                "model": self.model,
                "messages": messagePayload,
                "temperature": 0.7,
                "max_tokens": 500
            ]
            
            self.makeRequest(payload: payload, completion: completion)
        }
    }
    
    private func makeRequest(payload: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = apiKey else {
            DispatchQueue.main.async {
                completion(.failure(LLMError.missingAPIKey))
            }
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            DispatchQueue.main.async {
                completion(.failure(LLMError.invalidResponse))
            }
            return
        }
        
        guard let url = URL(string: self.endpoint) else {
            DispatchQueue.main.async {
                completion(.failure(LLMError.invalidResponse))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(LLMError.networkError(error.localizedDescription)))
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(.failure(LLMError.invalidResponse))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(content))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(LLMError.invalidResponse))
                    }
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
