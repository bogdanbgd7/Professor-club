//
//  CreateUserVC.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/25/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

class CreateUserVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var createUserBtn: CustomButton!
    @IBOutlet weak var cancelBtn: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func createUserPressed(_ sender: Any) {
        
        guard let email = emailTxt.text,
        let password = passwordTxt.text,
        let username = usernameTxt.text  else { return }
        
        //error ukoliko su prazna polja
        if username.isEmpty || password.isEmpty || username.isEmpty{
            let alert = UIAlertController.init(title: "Warning", message: "Please enter username and password", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        //ako je sve u redu onda
        else {
            
            //alert
            let alert12 = UIAlertController(title: "Successfully!", message: "Account is online!", preferredStyle: UIAlertController.Style.alert)
            let act = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            alert12.addAction(act)
            self.present(alert12, animated: true, completion: nil)
            
            //create user logic
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
                if let error = error {
                    debugPrint("Error creating user.\(error.localizedDescription)")
                }
                
                //since we used username and password for creating acc, we use our usernameTextField to be DisplayName from USERS
                let changeRequest = user?.user.createProfileChangeRequest()
                changeRequest?.displayName = username //username.text
                changeRequest?.commitChanges(completion: { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                })
                
                //         Making USERS collection
                guard let userID = user?.user.uid else { return }
                //we still don't have collection USERS
                Firestore.firestore().collection(USERS_REF).document(userID).setData([
                    USERNAME : username, //username from text
                    DATE_CREATED : FieldValue.serverTimestamp() //current time
                    ], completion: { (error) in
                        
                        if let error = error {
                            debugPrint(error.localizedDescription)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                })
            }
        }
        
      
        
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
