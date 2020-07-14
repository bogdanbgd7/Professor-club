//
//  CommentsVC.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/26/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentDelegate {
    
    func commentOptionsTapped(comment: Comment) {
        
        //Alerts & Actions
        let alert = UIAlertController(title: "Warning!", message: "You are about to edit or delete your comment.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default) { (action) in
            
            let alert77 = UIAlertController(title: "Commented deleted!", message: "Successfully", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
            
            alert77.addAction(okAction)
            self.present(alert77, animated: true, completion: nil)
            
            
            self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                
                //READING DOCUMENT WITH DOCUMENT SNAPSHOT
                let thoughtDocument : DocumentSnapshot
                do {
                    try thoughtDocument = transaction.getDocument(self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId))
                } catch let error as NSError {
                    debugPrint("Fetch error : \(error.localizedDescription)")
                    return nil
                }
                
                guard let oldNumLikes = thoughtDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
                
                //updating our NUM_COMMENTS along with deleting comment
                transaction.updateData([NUM_COMMENTS : oldNumLikes - 1], forDocument: self.thoughtRef)
                
                //reference to comment document id
                let commentRef = self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId).collection(COMMENTS_REF).document(comment.documentId)
                
                transaction.deleteDocument(commentRef)
                
                return nil
                
            }) { (object, err) in
                if let err = err {
                    debugPrint("Transaction failed. \(err.localizedDescription)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
        let editAction = UIAlertAction(title: "Edit", style: UIAlertAction.Style.default) { (action) in
            
            self.performSegue(withIdentifier: "goToEditComment", sender: (comment, self.thought))
            alert.dismiss(animated: true, completion: nil)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (action) in
            
        }
        
       
        
        //Adding actions to alert
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EditCommentVC {
            if let commentData = sender as? (comment : Comment, thought : Thought) {
                destination.commentData = commentData
            }
        }
    }
    
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addComentTxt: UITextField!
    @IBOutlet weak var keyboardView: UIView!
    
    //we need to pass thought object from  our mainVC
    
    //Variables
    var thought : Thought!
    var comments = [Comment]()
    var thoughtRef : DocumentReference!
    let firestore = Firestore.firestore()
    var username : String! // USERNAME OF CURRENT USER
    private var commentsListener : ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        thoughtRef = firestore.collection(THOUGHTS_REF).document(thought.documentId)
        
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        self.view.bindToKeyboard()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        commentsListener = firestore.collection(THOUGHTS_REF).document(self.thought.documentId).collection(COMMENTS_REF)
            .order(by: TIMESTAMP, descending: false)
            .addSnapshotListener({ (snapshot, err) in
            
            guard let snapshot = snapshot else {
                debugPrint("error fetching comments\(err?.localizedDescription)")
                return
            }
                self.comments.removeAll() //without duplicates
                self.comments = Comment.parseData(snapshot: snapshot)
                self.tableView.reloadData()
            
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        commentsListener.remove()
    }
    
    @IBAction func addCommentPressed(_ sender: Any) {
        
        
        
        if addComentTxt.text != "" {
            
            let alert = UIAlertController(title: "Successfully!", message: "Comment is online!", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            guard let commentText = addComentTxt.text else { return }
            
            firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                
                let thoughtDocument : DocumentSnapshot
                do {
                    try thoughtDocument = transaction.getDocument(self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId))
                } catch let error as NSError {
                    debugPrint("Fetch error : \(error.localizedDescription)")
                    return nil
                }
                
                guard let oldNumLikes = thoughtDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
                
                transaction.updateData([NUM_COMMENTS : oldNumLikes + 1], forDocument: self.thoughtRef)
                //making new document called comments which is stored in Constants as COMMENTS_REF
                let newCommentRef = self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId).collection(COMMENTS_REF).document()
                
                transaction.setData([
                    COMMENT_TXT : commentText,
                    TIMESTAMP : FieldValue.serverTimestamp(),
                    USERNAME : self.username,
                    USER_ID : Auth.auth().currentUser?.uid ?? ""
                    
                    ], forDocument: newCommentRef)
                
                return nil
                
            }) { (object, err) in
                if let err = err {
                    debugPrint("Transaction failed. \(err.localizedDescription)")
                } else {
                    self.addComentTxt.text = ""
                    self.addComentTxt.resignFirstResponder()
                }
            }
        }
        else {
            
            let alert = UIAlertController(title: "Warning!", message: "Field is empty.", preferredStyle: UIAlertController.Style.alert)
            let falseAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(falseAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell {
            
            cell.configureCell(comment: comments[indexPath.row], delegate: self)
            return cell
            
        }
        else {
             return UITableViewCell()
        }
 
       
    }
    



}
