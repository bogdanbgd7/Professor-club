//
//  CommentCell.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/26/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import UIKit
import Firebase

protocol CommentDelegate {
    func commentOptionsTapped(comment : Comment)
}

class CommentCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var timestampText: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var optionMenu: UIImageView!
    
    //Variables
    private var comment : Comment!
    private var delegate : CommentDelegate?


    func configureCell(comment : Comment, delegate : CommentDelegate?) {
        self.comment = comment
        self.delegate = delegate
        
        usernameText.text = comment.username
        commentText.text = comment.commentText
        
        optionMenu.isHidden = true
        
        //time
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, hh:mm"
        let timestamp = formater.string(from: comment.timestamp)
        timestampText.text = timestamp
        
        //making user can edit/delete only his comment, not the comments from others.
        if comment.userId == Auth.auth().currentUser?.uid {
            optionMenu.isHidden = false
            optionMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(commentOptionsTap))
            optionMenu.addGestureRecognizer(tap)
        }
    }
    
    @objc func commentOptionsTap() {
        delegate?.commentOptionsTapped(comment: comment)
    }

}
