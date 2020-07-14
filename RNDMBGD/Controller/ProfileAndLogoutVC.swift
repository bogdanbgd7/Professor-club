//
//  ProfileAndLogoutVC.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 1/3/19.
//  Copyright © 2019 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

class ProfileAndLogoutVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var usernameText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUserLabel = Auth.auth().currentUser?.displayName else {return}
        usernameText.text = currentUserLabel
        
    }


    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            self.dismiss(animated: true, completion: nil)
            
        } catch _ as NSError {
            debugPrint("error when signing out")
        }
    }
}
