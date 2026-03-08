//
//  ProfileViewController.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func logoutTapped(_ sender: UIButton) {
        UserSession.shared.logout()
            dismiss(animated: true)
    }

}
