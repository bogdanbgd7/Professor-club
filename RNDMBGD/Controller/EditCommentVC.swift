//
//  EditCommentVC.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 1/2/19.
//  Copyright © 2019 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

class EditCommentVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var commentText: UITextView!
    
    //Variables
    var commentData : (comment : Comment, thought : Thought)!
    let firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentText.layer.cornerRadius = 7
        
        commentText.text = commentData.comment.commentText
    }
    

    @IBAction func updateBtnPressed(_ sender: Any) {
        
        if commentText.text == "" {
            
            //print("error empty field")
            
            let alert = UIAlertController(title: "Warning", message: "Text is empty.", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
                
            }
            
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            
        }
        
        else {
            
            let alert12 = UIAlertController(title: "Successfully", message: "Your comment has been updated.", preferredStyle: UIAlertController.Style.alert)
            let act12 = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            alert12.addAction(act12)
            self.present(alert12, animated: true, completion: nil)
            
            //accessing our document in comments ref and updating it
            firestore.collection(THOUGHTS_REF).document(commentData.thought.documentId)
                .collection(COMMENTS_REF).document(commentData.comment.documentId)
                .updateData([COMMENT_TXT : commentText.text]) { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
            }
        }
        
        
        
    }
    
}
