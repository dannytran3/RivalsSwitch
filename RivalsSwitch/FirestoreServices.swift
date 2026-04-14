//
//  FirestoreService.swift
//  RivalsSwitch
//
//  Keeps Firestore reads/writes in one place so the rest of the app
//  can keep using UserSession, UserDefaults, and MatchStore.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirestoreService: NSObject {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()
    private var isObservingDefaults = false

    private override init() {
        super.init()
    }

    private var currentUID: String? {
        Auth.auth().currentUser?.uid
    }

    private func userDocument(uid: String) -> DocumentReference {
        db.collection("users").document(uid)
    }

    private func matchesCollection(uid: String) -> CollectionReference {
        userDocument(uid: uid).collection("matches")
    }

    func startPreferenceSyncObserver() {
        guard !isObservingDefaults else { return }
        isObservingDefaults = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    @objc private func userDefaultsDidChange() {
        guard currentUID != nil else { return }
        saveCurrentPreferences()
    }

    func createUserDocument(username: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = currentUID else {
            completion?(nil)
            return
        }

        let data: [String: Any] = [
            "username": username,
            "messagingTone": UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.messagingTone),
            "recommendationStyle": UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.recommendationStyle),
            "createdAt": FieldValue.serverTimestamp()
        ]

        userDocument(uid: uid).setData(data, merge: true) { error in
            completion?(error)
        }
    }

    func loadCurrentUserData(completion: ((Error?) -> Void)? = nil) {
        guard let uid = currentUID else {
            completion?(nil)
            return
        }

        userDocument(uid: uid).getDocument { snapshot, error in
            if let error = error {
                completion?(error)
                return
            }

            guard let snapshot = snapshot else {
                completion?(nil)
                return
            }

            if !snapshot.exists {
                let fallbackUsername =
                    Auth.auth().currentUser?.displayName ??
                    UserDefaults.standard.string(forKey: "username") ??
                    "User"

                self.createUserDocument(username: fallbackUsername) { createError in
                    completion?(createError)
                }
                return
            }

            let data = snapshot.data() ?? [:]

            if let username = data["username"] as? String, !username.isEmpty {
                UserDefaults.standard.set(username, forKey: "username")
            }

            if let tone = data["messagingTone"] as? Int {
                UserDefaults.standard.set(tone, forKey: AppPreferenceStore.Keys.messagingTone)
            } else if let tone = data["messagingTone"] as? NSNumber {
                UserDefaults.standard.set(tone.intValue, forKey: AppPreferenceStore.Keys.messagingTone)
            }

            if let style = data["recommendationStyle"] as? Int {
                UserDefaults.standard.set(style, forKey: AppPreferenceStore.Keys.recommendationStyle)
            } else if let style = data["recommendationStyle"] as? NSNumber {
                UserDefaults.standard.set(style.intValue, forKey: AppPreferenceStore.Keys.recommendationStyle)
            }

            completion?(nil)
        }
    }

    func saveCurrentPreferences(completion: ((Error?) -> Void)? = nil) {
        guard let uid = currentUID else {
            completion?(nil)
            return
        }

        let data: [String: Any] = [
            "messagingTone": UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.messagingTone),
            "recommendationStyle": UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.recommendationStyle)
        ]

        userDocument(uid: uid).setData(data, merge: true) { error in
            completion?(error)
        }
    }

    func updateUsername(_ username: String, completion: ((Error?) -> Void)? = nil) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else {
            completion?(nil)
            return
        }

        UserDefaults.standard.set(trimmedUsername, forKey: "username")

        if let currentUser = Auth.auth().currentUser {
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.displayName = trimmedUsername
            changeRequest.commitChanges { error in
                if let error = error {
                    completion?(error)
                    return
                }

                self.writeUsernameToFirestore(trimmedUsername, completion: completion)
            }
        } else {
            writeUsernameToFirestore(trimmedUsername, completion: completion)
        }
    }

    private func writeUsernameToFirestore(_ username: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = currentUID else {
            completion?(nil)
            return
        }

        userDocument(uid: uid).setData([
            "username": username
        ], merge: true) { error in
            completion?(error)
        }
    }

    func saveMatch(_ match: SavedMatch, completion: ((Error?) -> Void)? = nil) {
        guard let uid = currentUID else {
            completion?(nil)
            return
        }

        let data: [String: Any] = [
            "savedAt": Timestamp(date: match.savedAt),
            "summary": match.summary
        ]

        matchesCollection(uid: uid).document(match.id).setData(data) { error in
            completion?(error)
        }
    }

    func deleteMatch(matchID: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = currentUID else {
            completion?(nil)
            return
        }

        matchesCollection(uid: uid).document(matchID).delete { error in
            completion?(error)
        }
    }

    func loadMatches(completion: ((Error?) -> Void)? = nil) {
        guard let uid = currentUID else {
            MatchStore.shared.replaceSavedMatches([])
            completion?(nil)
            return
        }

        matchesCollection(uid: uid)
            .order(by: "savedAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion?(error)
                    return
                }

                let docs = snapshot?.documents ?? []
                let matches: [SavedMatch] = docs.map { doc in
                    let data = doc.data()
                    let savedAt = (data["savedAt"] as? Timestamp)?.dateValue() ?? Date()
                    let summary = data["summary"] as? String ?? ""

                    return SavedMatch(
                        id: doc.documentID,
                        savedAt: savedAt,
                        summary: summary
                    )
                }

                MatchStore.shared.replaceSavedMatches(matches)
                completion?(nil)
            }
    }

    func bootstrapCurrentUserData(completion: (() -> Void)? = nil) {
        guard currentUID != nil else {
            completion?()
            return
        }

        let group = DispatchGroup()

        group.enter()
        loadCurrentUserData { _ in
            group.leave()
        }

        group.enter()
        loadMatches { _ in
            group.leave()
        }

        group.notify(queue: .main) {
            completion?()
        }
    }
}
