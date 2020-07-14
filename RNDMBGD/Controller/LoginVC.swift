//
//  LoginVC.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/25/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var dontHaveAccLabel: UILabel!
    @IBOutlet weak var loginBtn: CustomButton!
    @IBOutlet weak var singUpButton: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        guard let usernameFromTxt = usernameTxt.text else {return}
        guard let passwordFromTxt = passwordTxt.text else {return}
        
        if usernameFromTxt.isEmpty || passwordFromTxt.isEmpty {
            let alert = UIAlertController.init(title: "Warning", message: "Please type username and password", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
         
        } else {
            
            Auth.auth().signIn(withEmail: usernameFromTxt, password: passwordFromTxt) { (user, error) in
                
                if let error = error
                {
                    
                    debugPrint(error.localizedDescription)
                    
                    //alert for user 
                    let alert = UIAlertController.init(title: "Warning", message: error.localizedDescription , preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                  
                    }
                    else {
                    
                    guard let currentUserUsername = Auth.auth().currentUser?.displayName else { return }
                    
                    let alert = UIAlertController(title: "Professor club", message: "Welcome!  \n \(currentUserUsername)", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(action)
                    
                    let mainvc = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        mainvc?.present(alert, animated: true, completion: nil)
                    })
                    
                    
                    
                }
            }
        }
        
        
    }

    
}
    

    
    
        
    


