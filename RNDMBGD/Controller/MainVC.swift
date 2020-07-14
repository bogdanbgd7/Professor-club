//
//  ViewController.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/25/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

enum ThoughtCategory : String {
    case serious = "serious"
    case funny = "funny"
    case crazy = "crazy"
    case popular = "popular"
}

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ThoughtDelegate {
    
    //Outlets
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    
    //Variables
    private var thougths = [Thought]() //array of thoughts
    private var thoughtCollectionRef : CollectionReference! //used for adding, getting and quering documents
    private var thoughtsListener : ListenerRegistration!
    private var selectedCategory = ThoughtCategory.funny.rawValue
    private var handler : AuthStateDidChangeListenerHandle?
    var username : String!
    
    
    @IBAction func itemBtnPressed(_ sender: Any) {
        //Navigating to xib file from MainVC 
                let profile = ProfileAndLogoutVC()
                profile.modalPresentationStyle = .custom
                present(profile, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //samo za diplomski
        print("Serverska greška. Brisanje neuspelo.")
        
        //table view delegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        thoughtCollectionRef =  Firestore.firestore().collection(THOUGHTS_REF)
        
        //current user
        guard let currentUserUsername = Auth.auth().currentUser?.displayName else { return }
        
        let alert = UIAlertController(title: "Professor club!", message: "Welcome \(currentUserUsername)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

        

        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        handler = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil { //if we are not logged in, go to loginVC.
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                self.present(loginVC, animated: true, completion: nil)
            } else {
               self.setListener()
            }
        })
       
    }
    
    func setListener() {
        
        if selectedCategory == ThoughtCategory.popular.rawValue {
            thoughtsListener =  thoughtCollectionRef
                .order(by: NUM_LIKES, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let error = error {
                        debugPrint("Error fetching document \(error)")
                    } else {
                        self.thougths.removeAll() // removeAll() because of not making duplicates in tableview when reload tableview
                        
                        self.thougths = Thought.parseData(snapshot: snapshot)
                        
                        self.tableView.reloadData()
                        
                       
                    }
                    
            }
            
        } else {
            thoughtsListener =  thoughtCollectionRef
                .whereField(CATEGORY, isEqualTo: selectedCategory)
                .order(by: TIMESTAMP, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let error = error {
                        debugPrint("Error fetching document \(error)")
                    } else {
                        self.thougths.removeAll() // removeAll() because of not making duplicates in tableview when reload tableview
                        
                        self.thougths = Thought.parseData(snapshot: snapshot)
                        
                        self.tableView.reloadData()
                        
                        //self.username = USERNAME
                    }
                    
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if thoughtsListener  != nil {
            thoughtsListener.remove()
        }
        
    }
    
    
    func thoughtOptionsTapped(thought: Thought) {
        //This is where we create the alert to handle the deletion.
        let alert = UIAlertController(title: "Warning", message: "You'll delete this.", preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default) { (action) in
            
        
            Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentId).delete(completion: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                } else {
                    let alert12 = UIAlertController(title: "Deleted", message: "Successfuly deleted.", preferredStyle: UIAlertController.Style.alert)
                    let act12 = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                    alert12.addAction(act12)
                    self.present(alert12, animated: true, completion: nil)
                    
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) { (action) in
            
        }
        
       
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func categoryChanged(_ sender: Any) {
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectedCategory = ThoughtCategory.funny.rawValue
        case 1 :
            selectedCategory = ThoughtCategory.serious.rawValue
        case 2 :
            selectedCategory = ThoughtCategory.crazy.rawValue
            
        default:
            selectedCategory = ThoughtCategory.popular.rawValue
        }
        
        thoughtsListener.remove()
        setListener()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return thougths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //we want to configure our custom cell.
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as? ThoughtCell{
            
            cell.configureCell(thought: thougths[indexPath.row], delegate: self)
            return cell
            
        } else {
            
            return UITableViewCell()
            
        }
        
    }
    
    //when we click on one of our table view items, go to comments
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToComments", sender: thougths[indexPath.row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToComments" {
            if let destinationVC = segue.destination as? CommentsVC {
                if let thought = sender as? Thought {
                    destinationVC.thought = thought
                }
            }
        }
    }


}

