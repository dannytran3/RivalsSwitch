//
//  RecommendationsViewController.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import UIKit

class RecommendationsViewController: UIViewController {

    @IBOutlet weak var switch1HeroLabel: UILabel!
    @IBOutlet weak var switch1ReasonLabel: UILabel!

    @IBOutlet weak var switch2HeroLabel: UILabel!
    @IBOutlet weak var switch2ReasonLabel: UILabel!

    @IBOutlet weak var switch3HeroLabel: UILabel!
    @IBOutlet weak var switch3ReasonLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        switch1HeroLabel.text = MatchStore.shared.recommendedHero1
        switch1ReasonLabel.text = MatchStore.shared.recommendedReason1

        switch2HeroLabel.text = MatchStore.shared.recommendedHero2
        switch2ReasonLabel.text = MatchStore.shared.recommendedReason2

        switch3HeroLabel.text = MatchStore.shared.recommendedHero3
        switch3ReasonLabel.text = MatchStore.shared.recommendedReason3
    }

    @IBAction func saveMatchTapped(_ sender: UIButton) {
        MatchStore.shared.saveCurrentMatch()

        let alert = UIAlertController(title: "Saved", message: "Match added to history.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
