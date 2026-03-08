//
//  ConfirmEnemyTeamViewController.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import UIKit

class ConfirmEnemyTeamViewController: UIViewController {

    @IBOutlet weak var enemy1TextField: UITextField!
    @IBOutlet weak var enemy2TextField: UITextField!
    @IBOutlet weak var enemy3TextField: UITextField!
    @IBOutlet weak var enemy4TextField: UITextField!
    @IBOutlet weak var enemy5TextField: UITextField!
    @IBOutlet weak var enemy6TextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        enemy1TextField.text = MatchStore.shared.enemy1
        enemy2TextField.text = MatchStore.shared.enemy2
        enemy3TextField.text = MatchStore.shared.enemy3
        enemy4TextField.text = MatchStore.shared.enemy4
        enemy5TextField.text = MatchStore.shared.enemy5
        enemy6TextField.text = MatchStore.shared.enemy6
    }

    @IBAction func doneTapped(_ sender: UIButton) {

        let enemyTeam = [
            MatchStore.shared.enemy1,
            MatchStore.shared.enemy2,
            MatchStore.shared.enemy3,
            MatchStore.shared.enemy4,
            MatchStore.shared.enemy5,
            MatchStore.shared.enemy6
        ]

        let recs = RecommendationEngine.generateRecommendations(
            hero: MatchStore.shared.currentHero,
            kills: MatchStore.shared.currentKills,
            deaths: MatchStore.shared.currentDeaths,
            assists: MatchStore.shared.currentAssists,
            enemyTeam: enemyTeam
        )

        if recs.count > 0 {
            MatchStore.shared.recommendedHero1 = recs[0].0
            MatchStore.shared.recommendedReason1 = recs[0].1
        }

        if recs.count > 1 {
            MatchStore.shared.recommendedHero2 = recs[1].0
            MatchStore.shared.recommendedReason2 = recs[1].1
        }

        if recs.count > 2 {
            MatchStore.shared.recommendedHero3 = recs[2].0
            MatchStore.shared.recommendedReason3 = recs[2].1
        }

        performSegue(withIdentifier: "toRecommendations", sender: self)
    }

    @IBAction func editTapped(_ sender: UIButton) {
        // fields editable already
    }
}
