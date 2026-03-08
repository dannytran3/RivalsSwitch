//
//  HomeViewController.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let username = UserSession.shared.username {
            welcomeLabel.text = "Welcome, \(username)"
        }
    }

    @IBAction func startNewMatchTapped(_ sender: UIButton) {
        MatchStore.shared.clearCurrentMatch()
        performSegue(withIdentifier: "startMatchFlow", sender: self)
    }
}

