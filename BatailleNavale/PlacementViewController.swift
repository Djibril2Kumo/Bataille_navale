//
//  PlacementViewController.swift
//  BatailleNavale
//
//  Created by Lucas Varsavaux on 07/06/2024.
//

import UIKit
// PlacementViewController gère le placement des bateaux pour le joueur 1
class PlacementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Outlets pour les éléments de l'interface utilisateur
    @IBOutlet weak var tableView: UITableView! //variable qui est lie la tableview (grille) à la view placementviewcontroller
    @IBOutlet weak var resetButton: UIButton! //bouton qui reset la grille
    @IBOutlet weak var lblIresultbat: UILabel! //bouton qui indique si la grille est rempli
    @IBOutlet weak var attackButton: UIButton! // Bouton pour passer à l'écran d'attaque
    
    var gridSize: Int = 6 // Taille par défaut de la grille (6x6)
    
    var selectedButton: UIButton? // Bouton actuellement sélectionné par le joueur pour commencer à placer le bateau. Utilisé pour suivre le point de départ du placement du bateau.
    
    var availableButtons: [UIButton] = [] // Liste des boutons disponibles pour le placement du bateau à partir du bouton sélectionné. Ces boutons sont mis en surbrillance pour montrer les positions possibles pour le bateau.
    var isShipPlaced: Bool = false // Indicateur de l'état de placement du bateau. Devient true une fois que le bateau est placé sur la grille.
    
    var shipPositions: Set<Position> = [] // Ensemble des positions des boutons qui composent le bateau placé. Utilisé pour stocker et vérifier les positions du bateau sur la grille.

    // Méthode appelée lorsque la vue est chargée
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration de la table view
        tableView.dataSource = self
        tableView.delegate = self
        
        resetButton.isEnabled = false // Désactiver le bouton de réinitialisation au départ
        lblIresultbat.text = "" // Initialisez le texte du label à vide
        attackButton.isEnabled = false // Désactiver le bouton d'attaque jusqu'à ce que le bateau soit placé
    }
    // Nombre de sections dans la table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Nombre de lignes dans chaque section (dépend de la taille de la grille)
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
            //button.setTitle("\(row),\(col)", for: .normal)
            button.backgroundColor = .systemTeal
            button.setTitleColor(.white, for: .normal)
            button.tag = row * gridSize + col
            button.isEnabled = !isShipPlaced
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }
    
    // Action lorsque le bouton est tapé
    @objc func buttonTapped(_ sender: UIButton) {
        guard let selectedButton = self.selectedButton else {
            self.selectedButton = sender
            highlightAvailablePositions(from: sender)
            return
        }
        
        if availableButtons.contains(sender) {
            placeShip(at: sender)
        } else {
            clearSelection()
            self.selectedButton = sender
            highlightAvailablePositions(from: sender)
        }
    }
    
    // Mise en surbrillance des positions disponibles pour le placement du bateau
    func highlightAvailablePositions(from button: UIButton) {
        let row = button.tag / gridSize
        let col = button.tag % gridSize
        
        let positions = [
            (row, col - 2), (row, col - 1), (row, col + 1), (row, col + 2), // Horizontal positions
            (row - 2, col), (row - 1, col), (row + 1, col), (row + 2, col)  // Vertical positions
        ]
        
        for pos in positions {
            if isValidPosition(row: pos.0, col: pos.1) {
                if let btn = buttonAtPosition(row: pos.0, col: pos.1) {
                    availableButtons.append(btn)
                    btn.backgroundColor = .systemYellow
                }
            }
        }
    }
    
    // Vérifie si la position est valide
    func isValidPosition(row: Int, col: Int) -> Bool {
        return row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }
    
    // Retourne le bouton à une position donnée
    func buttonAtPosition(row: Int, col: Int) -> UIButton? {
        let indexPath = IndexPath(row: row, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? btnviewcell {
            guard col < cell.buttonPlace.count else { return nil }
            return cell.buttonPlace[col]
        }
        return nil
    }
    
    // Place le bateau à la position sélectionnée
    func placeShip(at button: UIButton) {
        guard let selectedButton = self.selectedButton else { return }
        
        let selectedRow = selectedButton.tag / gridSize
        let selectedCol = selectedButton.tag % gridSize
        let targetRow = button.tag / gridSize
        let targetCol = button.tag % gridSize
        
        if selectedRow == targetRow {
            // Horizontal placement
            let startCol = min(selectedCol, targetCol)
            let endCol = max(selectedCol, targetCol)
            
            if endCol - startCol == 1 {
                if let btnLeft = buttonAtPosition(row: selectedRow, col: startCol - 1) {
                    availableButtons.append(btnLeft)
                }
                if let btnRight = buttonAtPosition(row: selectedRow, col: endCol + 1) {
                    availableButtons.append(btnRight)
                }
            }
            
            for col in startCol...(startCol + 2) {
                if let btn = buttonAtPosition(row: selectedRow, col: col) {
                    btn.backgroundColor = .systemGreen
                    btn.isEnabled = false
                    shipPositions.insert(Position(row: selectedRow, col: col)) // Enregistrer la position du bouton
                }
            }
        } else if selectedCol == targetCol {
            // Vertical placement
            let startRow = min(selectedRow, targetRow)
            let endRow = max(selectedRow, targetRow)
            
            if endRow - startRow == 1 {
                if let btnTop = buttonAtPosition(row: startRow - 1, col: selectedCol) {
                    availableButtons.append(btnTop)
                }
                if let btnBottom = buttonAtPosition(row: endRow + 1, col: selectedCol) {
                    availableButtons.append(btnBottom)
                }
            }
            
            for row in startRow...(startRow + 2) {
                if let btn = buttonAtPosition(row: row, col: selectedCol) {
                    btn.backgroundColor = .systemGreen
                    btn.isEnabled = false
                    shipPositions.insert(Position(row: row, col: selectedCol)) // Enregistrer la position du bouton
                }
            }
        }
        
        isShipPlaced = true
        resetButton.isEnabled = true
        attackButton.isEnabled = true // Activer le bouton d'attaque
        lblIresultbat.text = "Vous avez placé le bateau" // Met à jour le texte du label
        tableView.reloadData()
    }
    
    // Efface la sélection actuelle des boutons choisi
    func clearSelection() {
        selectedButton?.backgroundColor = .systemBlue
        selectedButton = nil
        
        for btn in availableButtons {
            btn.backgroundColor = .systemBlue
        }
        availableButtons.removeAll()
    }
    
    // Action du bouton de réinitialisation
    @IBAction func resetTapped(_ sender: UIButton) {
          selectedButton = nil
          availableButtons.removeAll()
          isShipPlaced = false
          shipPositions.removeAll() // Réinitialiser les positions du bateau
          resetButton.isEnabled = false
          attackButton.isEnabled = false // Désactiver le bouton d'attaque
          lblIresultbat.text = "" // Réinitialisez le texte du label
          tableView.reloadData()
    }
    
    // Action du bouton d'attaque
    @IBAction func attackButtonTapped(_ sender: UIButton) {
        // Passer à l'écran d'attaque
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
              if let attackVC = storyboard.instantiateViewController(withIdentifier: "AttackViewController") as? AttackViewController {
                  attackVC.gridSize = self.gridSize
                  attackVC.shipPositions = self.shipPositions
                  self.navigationController?.pushViewController(attackVC, animated: true)
              }
        }
}
    
