//
//  ThoughtCell.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/25/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

protocol ThoughtDelegate {
    func  thoughtOptionsTapped(thought : Thought)
}

class ThoughtCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var thoughtTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var commentsImage: UIImageView!
    @IBOutlet weak var comentsNumberLabel: UILabel!
    @IBOutlet weak var optionMenu: UIImageView!
    
    
    //Variables
    private var thought : Thought!
    private var delegate : ThoughtDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
        
    }
    
    @objc func likeTapped() {
        
       
        
        //setData znaci menja dokument unutar kolekcije THOUGHTS_REF
        Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentId).setData([NUM_LIKES : thought.numLikes + 1], merge: true)
    }
    
    func configureCell(thought : Thought, delegate : ThoughtDelegate) {
        self.thought = thought
        self.delegate = delegate
        
        optionMenu.isHidden = true
        
        usernameLabel.text = thought.usernameThought
        thoughtTextLabel.text = thought.thoughtTxt
        likesNumberLabel.text = String(thought.numLikes)
        comentsNumberLabel.text = String(thought.numComments)
        
        //timestamp
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, hh:mm"
        let timestamp = formater.string(from: thought.timestamp)
        timestampLabel.text = timestamp
        
        //checking wethher current user made that post or not, if is, then he could tap on optionMenu
        if thought.userId == Auth.auth().currentUser?.uid {
           
            optionMenu.isHidden = false
            optionMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(thoughtOptionsTapped))
            optionMenu.addGestureRecognizer(tap) //making sure optionMenu is tappable.
            
        }
        
    }
    
    @objc func thoughtOptionsTapped() {
        delegate?.thoughtOptionsTapped(thought: thought)
        
    }
    

}
