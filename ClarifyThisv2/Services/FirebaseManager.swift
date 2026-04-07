import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import Combine

// MARK: - History Models
struct HistoryMessage: Codable, Hashable {
    let role: String
    let content: String
}

struct ChatSession: Codable, Identifiable {
    let id: String
    let date: Date
    let preview: String
    let messages: [HistoryMessage]
}

// MARK: - Firebase Manager

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    // MARK: - Published Properties
    @Published var history: [ChatSession] = []
    
    private init() {
        loadHistory()
    }
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    var userEmail: String? {
        return currentUser?.email
    }
    
    var userName: String? {
        return currentUser?.displayName ?? currentUser?.email?.components(separatedBy: "@").first
    }
    
    var userInitials: String {
        guard let name = userName else { return "?" }
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            let first = String(components[0].prefix(1))
            let last = String(components[1].prefix(1))
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
    
    // MARK: - History Management
    
    func saveSession(id: String, roleContentPairs: [(role: String, content: String)]) {
        let historyMessages = roleContentPairs.map { HistoryMessage(role: $0.role, content: $0.content) }
        
        let firstQuestion = historyMessages.first(where: { $0.role == "user" && !$0.content.contains("Simplify") })?.content ?? "New Conversation"
        let previewText = String(firstQuestion.prefix(60)) + (firstQuestion.count > 60 ? "..." : "")
        
        let session = ChatSession(id: id, date: Date(), preview: previewText, messages: historyMessages)
        
        DispatchQueue.main.async {
            if let index = self.history.firstIndex(where: { $0.id == id }) {
                self.history[index] = session
            } else {
                self.history.insert(session, at: 0)
            }
            self.persistHistory()
        }
    }
    
    private func persistHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "user_chat_history")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "user_chat_history"),
           let decoded = try? JSONDecoder().decode([ChatSession].self, from: data) {
            self.history = decoded
        }
    }
    
    // MARK: - Auth Methods
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error { completion(.failure(error)); return }
            guard let user = result?.user else { return }
            completion(.success(user))
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error { completion(.failure(error)); return }
            guard let user = result?.user else { return }
            completion(.success(user))
        }
    }
    
    func signInWithGoogle(presentingWindow: NSWindow, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingWindow) { result, error in
            if let error = error { completion(.failure(error)); return }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error { completion(.failure(error)); return }
                guard let user = authResult?.user else { return }
                completion(.success(user))
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
