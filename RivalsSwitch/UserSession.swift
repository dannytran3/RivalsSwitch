//
//  UserSession.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import Foundation
import FirebaseAuth

class UserSession {
    static let shared = UserSession()
    private init() {}

    private let usernameKey = "username"

    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    var username: String? {
        get {
            Auth.auth().currentUser?.displayName ?? UserDefaults.standard.string(forKey: usernameKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: usernameKey)
        }
    }

    // Convert username into a email so users dont have to make an email for testing purposes.
    private func email(for username: String) -> String {
        let cleanedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return "\(cleanedUsername)@rivalsswitch.app"
    }

    func register(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email(for: trimmedUsername)

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            self?.username = trimmedUsername

            // Save the username as the Firebase display name too.
            let changeRequest = authResult?.user.createProfileChangeRequest()
            changeRequest?.displayName = trimmedUsername
            changeRequest?.commitChanges { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
        }
    }

    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email(for: trimmedUsername)

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Cache the username for easy access in the UI.
            self?.username = trimmedUsername
            completion(.success(()))
        }
    }

    func logout() {
        try? Auth.auth().signOut()
    }
}
