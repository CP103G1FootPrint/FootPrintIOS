//
//  Likes.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/27.
//  Copyright © 2019 lulu. All rights reserved.
//

class Likes: Codable {
    var userId:String
    var imageId:Int
    
    public init(_ userId: String, _ imageId: Int){
        self.userId = userId
        self.imageId = imageId
    }
}

