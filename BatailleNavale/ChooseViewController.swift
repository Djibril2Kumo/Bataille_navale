//
//  ChooseViewController.swift
//  BatailleNavale
//
//  Created by Lucas Varsavaux on 07/06/2024.
//
import UIKit

// ChooseViewController gère la sélection du mode de jeu (facile ou difficile) et le basculement entre le mode solo et le mode multijoueur.
class ChooseViewController: UIViewController {
    
    @IBOutlet weak var soloModeSwitch: UISwitch! // UISwitch pour activer/désactiver le mode solo
    @IBOutlet weak var modeLabel: UILabel! // Label pour afficher le mode sélectionné (solo ou multijoueur)
    
    // Méthode appelée lorsque la vue est chargée
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModeLabel() // Mettre à jour le label au démarrage
    }
    // Action appelée lorsque le toggle est changé
    @IBAction func soloModeSwitchChanged(_ sender: UISwitch) {
        updateModeLabel()
    }
    
    // Action appelée lorsque le bouton pour le mode facile est tapé
    @IBAction func ChooseEasyViewController(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
              if soloModeSwitch.isOn {
                  // Mode solo avec bot
                  // Mode facile avec une grille de 6x6, Place le bateau du bot , Passer à l'écran d'attaque
                  if let attackVC = storyboard.instantiateViewController(withIdentifier: "AttackViewController") as? AttackViewController {
                      attackVC.gridSize = 6
                      attackVC.shipPositions = placeBotShips(gridSize: 6)
                      self.navigationController?.pushViewController(attackVC, animated: true)
                  }
              } else {
                  // Mode multijoueur
                  if let placementVC = storyboard.instantiateViewController(withIdentifier: "PlacementViewController") as? PlacementViewController {
                      placementVC.gridSize = 6 // Mode facile avec une grille de 6x6
                      self.navigationController?.pushViewController(placementVC, animated: true) // Passer à l'écran de placement du bateau
                  }
              }
    }
    
    // Action appelée lorsque le bouton pour le mode difficile est tapé
    @IBAction func ChooseDifficultViewController(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
              if soloModeSwitch.isOn {
                  // Mode solo avec bot
                  // Mode difficile avec une grille de 12x12, Place le bateau du bot , Passer à l'écran d'attaque
                  if let attackVC = storyboard.instantiateViewController(withIdentifier: "AttackViewController") as? AttackViewController {
                      attackVC.gridSize = 12
                      attackVC.shipPositions = placeBotShips(gridSize: 12)
                      self.navigationController?.pushViewController(attackVC, animated: true)
                  }
              } else {
                  // Mode multijoueur
                  if let placementVC = storyboard.instantiateViewController(withIdentifier: "PlacementDifficultViewController") as? PlacementDifficultViewController {
                      placementVC.gridSize = 12 // Mode difficile avec une grille de 12x12
                      self.navigationController?.pushViewController(placementVC, animated: true) // Passer à l'écran de placement du bateau
                  }
              }
        }
    
    // Fonction pour mettre à jour le texte du label en fonction de l'état du toggle
      func updateModeLabel() {
          if soloModeSwitch.isOn {
              modeLabel.text = "Mode Solo" // Mettre à jour le label pour indiquer le mode solo
          } else {
              modeLabel.text = "Mode Multijoueur" // Mettre à jour le label pour indiquer le mode multijoueur
          }
      }
        
    
    // Fonction pour placer les bateaux du bot
    func placeBotShips(gridSize: Int) -> Set<Position> {
         var shipPositions: Set<Position> = []
         while shipPositions.count < 3 {
             let randomRow = Int.random(in: 0..<gridSize) // Générer une ligne aléatoire
             let randomCol = Int.random(in: 0..<gridSize) // Générer une colonne aléatoire
             let position = Position(row: randomRow, col: randomCol) // Créer une position avec les coordonnées aléatoires
             if shipPositions.insert(position).inserted {
                 // Ajouter des positions adjacentes pour simuler un bateau de 3 cases
                 if shipPositions.count < 3 && randomCol + 2 < gridSize {
                     shipPositions.insert(Position(row: randomRow, col: randomCol + 1))
                     shipPositions.insert(Position(row: randomRow, col: randomCol + 2))
                 } else if shipPositions.count < 3 && randomRow + 2 < gridSize {
                     shipPositions.insert(Position(row: randomRow + 1, col: randomCol))
                     shipPositions.insert(Position(row: randomRow + 2, col: randomCol))
                 }
             }
         }
         return shipPositions
     }
}
