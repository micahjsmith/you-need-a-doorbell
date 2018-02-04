//
//  LogInViewController.swift
//  YouNeedADoorbell
//
//  Created by Micah Smith on 2/3/18.
//  Copyright © 2018 Micah Smith. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    
    @IBAction func logInPressed(_ sender: Any) {
        logIn()
    }
    
    
    func logIn(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard email.contains("@") && email.contains(".") else {
            UIAlertController.showSimpleAlert(withTitle: "Invalid email", andMessage: "Invalid email address", on: self)
            return
        }
        guard password.count >= 8 else {
            UIAlertController.showSimpleAlert(withTitle: "Invalid password", andMessage: "Minimum password length is 8", on: self)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                UserDefaults.standard.set(true, forKey: "loggedIn")
                self.performSegue(withIdentifier: "load_application", sender: self)
            } else {
                UIAlertController.showSimpleAlert(withTitle: "Error", andMessage: "Could not log in", on: self)
            }
        })
    }
    
}

extension UIAlertController {
    static func showSimpleAlert(withTitle title: String, andMessage message: String, on sender: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) in })
        alertController.addAction(okButton)
        sender.present(alertController, animated: true, completion: { () in })
    }
}
