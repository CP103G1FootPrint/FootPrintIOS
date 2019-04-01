//
//  Comment.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/30.
//  Copyright © 2019 lulu. All rights reserved.
//

class Comment: Codable {
    var commentId: Int
    var userId: String
    var message: String
    var imageId: Int
    
    init(_ commentId: Int, _ userId: String, _ message: String, _ imageId: Int ) {
        self.commentId = commentId
        self.userId = userId
        self.message = message
        self.imageId = imageId
    }
    
}
