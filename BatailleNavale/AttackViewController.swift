//
//  AttackViewController.swift
//  BatailleNavale
//
//  Created by Lucas Varsavaux on 07/06/2024.
//

import UIKit

// AttackViewController gère la logique d'attaque pour trouver les bateaux placés par l'adversaire ou le bot.
class AttackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Outlets pour les éléments de l'interface utilisateur
    @IBOutlet weak var tableView: UITableView! // variable qui le lie au tableview (grille) de ma attackviewcontroller
    @IBOutlet weak var lblAttackResult: UILabel! // resultat de l'attaque, (statut), (essai) etc
    @IBOutlet weak var lblTimer: UILabel! // Label pour afficher le temps restant
    
    var gridSize: Int = 6 // Valeur par défaut, ajustez si nécessaire
    var shipPositions: Set<Position> = [] // Positions des boutons du bateau placés par le joueur précédent ou le bot
    var attackedPositions: Set<Position> = [] // Positions déjà attaquées
    var hitPositions: Set<Position> = [] // Positions touchées
    var remainingAttempts: Int = 10 // Nombre maximum d'essais
    
    var timer: Timer? // Timer pour gérer le compte à rebours
    var remainingTime: Int = 60 // Temps en secondes

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration de la table view
        tableView.dataSource = self
        tableView.delegate = self
        
        lblAttackResult.text = "Essais restants : \(remainingAttempts)"
        lblTimer.text = "Temps restant : \(remainingTime) sec"
        
        // Démarrer le minuteur pour décompter le temps restant
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        // Désactiver le bouton de retour pour empêcher de revenir à l'écran précédent
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Cacher la barre de navigation
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Réafficher la barre de navigation
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Mise à jour du timer chaque seconde
    @objc func updateTimer() {
        remainingTime -= 1
        lblTimer.text = "Temps restant : \(remainingTime) sec"
        
        if remainingTime == 0 {
            endGame(won: false, message: "Temps écoulé. Vous avez perdu.")
        }
    }
    
    // Nombre de sections dans la table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Nombre de lignes dans chaque section (dépend de la taille de la grille en fonction du mode facile ou difficile)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gridSize
    }
    
    // Configuration de chaque cellule de la table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "celluletext", for: indexPath) as? btnviewcell else {
            return UITableViewCell()
        }
        configureCell(cell: cell, row: indexPath.row)
        return cell
    }
    
    // Configuration de chaque cellule avec les boutons représentant les positions
    func configureCell(cell: btnviewcell, row: Int) {
        for (index, button) in cell.buttonPlace.enumerated() {
            let col = index
            //button.setTitle("", for: .normal)
            button.backgroundColor = .systemTeal
            button.setTitleColor(.white, for: .normal)
            button.tag = row * gridSize + col
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            let position = Position(row: row, col: col)
            if attackedPositions.contains(position) {
                button.isEnabled = false
                if shipPositions.contains(position) {
                    button.backgroundColor = .systemRed // Touché
                } else {
                    button.backgroundColor = .systemGray // Manqué
                }
            } else {
                button.isEnabled = true
            }
        }
    }
    
    // Action lorsque le bouton est tapé
    @objc func buttonTapped(_ sender: UIButton) {
        let row = sender.tag / gridSize
        let col = sender.tag % gridSize
        let position = Position(row: row, col: col)
        
        attackedPositions.insert(position)
        
        if shipPositions.contains(position) {
            sender.backgroundColor = .systemRed // Touché
            lblAttackResult.text = "Touché!"
            hitPositions.insert(position)
            checkWinCondition()
        } else {
            sender.backgroundColor = .systemGray // Manqué
            lblAttackResult.text = "Manqué! \(proximityHint(for: position))"
            remainingAttempts -= 1
            lblAttackResult.text = "\(lblAttackResult.text!) Essais restants : \(remainingAttempts)"
        }
        
        if remainingAttempts == 0 {
            endGame(won: false, message: "Vous avez utilisé tous vos essais. Vous avez perdu.")
        }
        
        sender.isEnabled = false
        tableView.reloadData()
    }
    
    // Indiquer la proximité de l'attaque à l'utilisateur
    func proximityHint(for position: Position) -> String {
        var minDistance = Int.max
        for shipPosition in shipPositions {
            let distance = abs(shipPosition.row - position.row) + abs(shipPosition.col - position.col)
            minDistance = min(minDistance, distance)
        }
        if minDistance > 3 {
            return "Vous êtes loin."
        } else {
            return "Vous êtes proche."
        }
    }
    
    // Vérification des conditions de victoire
    func checkWinCondition() {
        if hitPositions == shipPositions {
            endGame(won: true, message: "Vous avez coulé le bateau !")
        }
    }
    
    // Terminer le jeu avec un message
    func endGame(won: Bool, message: String) {
        timer?.invalidate()
        let alert = UIAlertController(title: won ? "Victoire!" : "Défaite", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}
