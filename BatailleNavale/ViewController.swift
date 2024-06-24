//
//  ViewController.swift
//  BatailleNavale
//
//  Created by Lucas Varsavaux on 07/06/2024.
//

import UIKit

class ViewController: UIViewController {

    // Méthode appelée lorsque la vue est chargée
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnHome(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ChooseViewController = storyboard.instantiateViewController(withIdentifier: "ChooseViewController") as! ChooseViewController
        self.navigationController?.pushViewController(ChooseViewController, animated: true)
    }
    
}

