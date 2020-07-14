//
//  Thought.swift
//  RNDMBGD
//
//  Created by Bogdan Ponocko on 12/25/18.
//  Copyright © 2018 Bogdan Ponocko. All rights reserved.
//

import Foundation
import Firebase

class Thought {
    
    //private(set) -> we can read it from everywhere, but can be changed only within Class
    
    private(set) var usernameThought : String!
    private(set) var timestamp : Date!
    private(set) var thoughtTxt : String!
    private(set) var numLikes : Int!
    private(set) var numComments : Int!
    private(set) var documentId : String!
    //part 3 variables
    private(set) var userId : String!
    
    init(username : String, timestamp: Date, thoughtTxt : String, numLikes : Int, numComments : Int, documentID : String, userID : String){
        
        self.usernameThought = username
        self.timestamp = timestamp
        self.thoughtTxt = thoughtTxt
        self.numLikes = numLikes
        self.numComments = numComments
        self.documentId = documentID
        self.userId = userID
    }
    
    class func parseData(snapshot : QuerySnapshot?) -> [Thought] {
        var thoughts = [Thought]()
        
        guard let snap = snapshot else { return thoughts }
        for document in snap.documents {
            //print(document.data())
            
            let data = document.data()
            
            let username = data[USERNAME] as? String ?? "Anonymus"
            let timestamp = data[TIMESTAMP] as? Date ?? Date()
            let thoughtText = data[THOUGHT_TXT] as? String ?? "Random thought"
            let numLikes = data[NUM_LIKES] as? Int ?? 0
            let numComments = data[NUM_COMMENTS] as? Int ?? 0
            let documentId = document.documentID
            let userid = data[USER_ID] as? String ?? ""
            
            
            let newThought = Thought(username: username, timestamp: timestamp, thoughtTxt: thoughtText, numLikes: numLikes, numComments: numComments, documentID: documentId, userID : userid)
            
            thoughts.append(newThought)
            
        }
        
        
        return thoughts
    }
  
    
}
