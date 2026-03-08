//
//  HistoryViewController.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var matches: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        matches = MatchStore.shared.loadMatches()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = "Match \(matches.count - indexPath.row)"
        content.secondaryText = matches[indexPath.row]

        content.secondaryTextProperties.numberOfLines = 0

        cell.contentConfiguration = content

        return cell
    }
}
