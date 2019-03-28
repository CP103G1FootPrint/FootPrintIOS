//
//  News.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/14.
//  Copyright © 2019 lulu. All rights reserved.
//

class News: Codable {
    var imageID: Int?
    var description: String?
    var openState: String?
    var userID: String?
    var landMarkID: Int?
    var likesCount: String
    var likeId: Int?
    var collectionId: Int?
    var nickName: String?
    var landMarkName: String?
    
    public init(_ imageID: Int, _ description: String, _ openState: String, _ userID: String, _ landMarkID: Int, _ likesCount: String, _ likeId: Int, _ collectionId: Int, _ nickName: String, _ landMarkName: String) {
        self.imageID = imageID
        self.description = description
        self.openState = openState
        self.userID = userID
        self.landMarkID = landMarkID
        self.likesCount = likesCount
        self.likeId = likeId
        self.collectionId = collectionId
        self.nickName = nickName
        self.landMarkName = landMarkName
    }
    
    public init(_ likesCount: String, _ imageID: Int){
        self.likesCount = likesCount
        self.imageID = imageID
    }
}
