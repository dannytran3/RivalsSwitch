import UIKit

class ConfirmMyStatsViewController: UIViewController {

    @IBOutlet weak var heroTextField: UITextField!
    @IBOutlet weak var killsTextField: UITextField!
    @IBOutlet weak var deathsTextField: UITextField!
    @IBOutlet weak var assistsTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        heroTextField.text = MatchStore.shared.currentHero
        killsTextField.text = "\(MatchStore.shared.currentKills)"
        deathsTextField.text = "\(MatchStore.shared.currentDeaths)"
        assistsTextField.text = "\(MatchStore.shared.currentAssists)"
    }

    @IBAction func doneTapped(_ sender: UIButton) {

        MatchStore.shared.currentHero = heroTextField.text ?? ""
        MatchStore.shared.currentKills = Int(killsTextField.text ?? "") ?? 0
        MatchStore.shared.currentDeaths = Int(deathsTextField.text ?? "") ?? 0
        MatchStore.shared.currentAssists = Int(assistsTextField.text ?? "") ?? 0

        performSegue(withIdentifier: "toConfirmEnemyTeam", sender: self)
    }

    @IBAction func editTapped(_ sender: UIButton) {
        // Fields already editable
    }
}
