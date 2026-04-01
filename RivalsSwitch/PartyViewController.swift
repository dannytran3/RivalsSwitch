//
//  PartyViewController.swift
//  RivalsSwitch
//
//  UIKit wrapper for SwiftUI PartyView
//

import UIKit
import SwiftUI

class PartyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Create SwiftUI view
        let partyView = PartyView()
        
        // Wrap in UIHostingController
        let hostingController = UIHostingController(rootView: partyView)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Setup constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        // Match background color
        view.backgroundColor = UIColor(red: 0.102, green: 0.102, blue: 0.180, alpha: 1.0)
        hostingController.view.backgroundColor = .clear
    }
}
