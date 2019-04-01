//
//  PersonalPicture.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/31.
//  Copyright © 2019 lulu. All rights reserved.
//

class PersonalPicture: Codable {
    var imageID: Int
    
    public init(_ imageID: Int){
        self.imageID = imageID
    }
}
