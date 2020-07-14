//
//  AddThoughtVC.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/25/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase //covers all SDK from Firebase

class AddThoughtVC: UIViewController, UITextViewDelegate {
    
    // Outlets
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var usernameText: UITextField!
    @IBOutlet private weak var thoughtText: UITextView!
    @IBOutlet private weak var postBtn: CustomButton!
    
    
    // Variables
    private var selectedCategory = ThoughtCategory.funny.rawValue //keeps track which category is selected.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Making rounded Button and TextView
        postBtn.layer.cornerRadius = 4
        thoughtText.layer.cornerRadius = 4
        
        //text view delegate property
        thoughtText.delegate = self
        
        //MALO SMO SE POSPRDALI
        //ako neces da gledas Optional(), moras UVEK da stavljas GUARD LET
        guard let currentUserLabel = Auth.auth().currentUser?.displayName else {return}
        usernameText.placeholder = "User : \(currentUserLabel)"

       
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        thoughtText.text = ""
        thoughtText.textColor = UIColor.darkGray
        
    }
    
    
    @IBAction func categoryChanged(_ sender: Any) {
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectedCategory = ThoughtCategory.funny.rawValue
        case 1 :
            selectedCategory = ThoughtCategory.serious.rawValue
            
        default:
            selectedCategory = ThoughtCategory.crazy.rawValue
        }
        
    }
    

    @IBAction func postBtnPressed(_ sender: Any) {
        
//     guard let username = usernameText.text else { return }
        guard let username = Auth.auth().currentUser?.displayName else { return }
        //reference to our collection in Firestore
        //creating new document based on what we type in our VC
        Firestore.firestore().collection(THOUGHTS_REF).addDocument(data: [
            CATEGORY : selectedCategory,
            NUM_COMMENTS: 0,
            NUM_LIKES : 0,
            THOUGHT_TXT : thoughtText.text,
            TIMESTAMP : FieldValue.serverTimestamp(),
            USERNAME : username,
            USER_ID : Auth.auth().currentUser?.uid ?? "Unknown"
        
        ]) { (err) in
            
            //if there is some error, perform debugPrint
            if let err = err {
                debugPrint("Error adding document: \(err)")
            }
            //else there is NO error
            else {
                
                if self.thoughtText.text == "" {
                    
                    let alert11 = UIAlertController(title: "Warning", message: "Field is empty.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                    
                    alert11.addAction(okAction)
                    
                    self.present(alert11, animated: true, completion: nil)
                    
                    
                }
                else {
                    
                    let alert = UIAlertController(title: "Successfully!", message: "Deleted.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (act) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
               
     
            }
            
        }
        
    }
    
    
    
    
}
