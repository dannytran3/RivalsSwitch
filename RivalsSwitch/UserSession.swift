//
//  UserSession.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import Foundation

class UserSession {
    static let shared = UserSession()
    private init() {}

    var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isLoggedIn") }
        set { UserDefaults.standard.set(newValue, forKey: "isLoggedIn") }
    }

    var username: String? {
        get { UserDefaults.standard.string(forKey: "username") }
        set { UserDefaults.standard.set(newValue, forKey: "username") }
    }

    var password: String? {
        get { UserDefaults.standard.string(forKey: "password") }
        set { UserDefaults.standard.set(newValue, forKey: "password") }
    }

    func register(username: String, password: String) {
        self.username = username
        self.password = password
        self.isLoggedIn = true
    }

    func login(username: String, password: String) -> Bool {
        guard self.username == username, self.password == password else { return false }
        self.isLoggedIn = true
        return true
    }

    func logout() {
        isLoggedIn = false
    }
}
