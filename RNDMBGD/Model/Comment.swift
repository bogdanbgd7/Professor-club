//
//  Comment.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/26/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    //private(set) -> we can read it from everywhere, but can be changed only within Class
    
    private(set) var username : String!
    private(set) var timestamp : Date!
    private(set) var commentText : String!
    private(set) var documentId : String!
    private(set) var userId : String!
    
    
    init(username : String, timestamp: Date, commentText : String, documentID : String, userID : String){
        
        self.username = username
        self.timestamp = timestamp
        self.commentText = commentText
        self.documentId = documentID
        self.userId = userID
        
    }
    
    class func parseData(snapshot : QuerySnapshot?) -> [Comment] {
        var comments = [Comment]()

        guard let snap = snapshot else { return comments }
        for document in snap.documents {
            //print(document.data())

            let data = document.data()

            let username = data[USERNAME] as? String ?? "Anonymus"
            let timestamp = data[TIMESTAMP] as? Date ?? Date()
            let commentText = data[COMMENT_TXT] as? String ?? "Random txt"
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""
         

            let newComment = Comment(username: username, timestamp: timestamp, commentText: commentText, documentID : documentId, userID : userId)

            comments.append(newComment)

        }
        
       

        return comments
    }
    
    
}
