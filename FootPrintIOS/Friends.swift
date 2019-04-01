//
//  Friends.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/1.
//  Copyright © 2019 lulu. All rights reserved.
//
public class Friends: Codable{
    var friendsId: Int?
    var type: String?
    var inviter: String?
    var invitee: String?
    var message: String?
    var messageType: String?
    var state: Int?
    
    public init(_ friendsId: Int, _ type: String, _ inviter: String, _ invitee: String, _ message: String, _ messageType: String, _ state: Int){
        self.friendsId = friendsId
        self.type = type
        self.invitee = invitee
        self.inviter = inviter
        self.message = message
        self.messageType = messageType
        self.state = state
    }
    
    public init(_ inviter: String, _ invitee: String){
        self.inviter = inviter
        self.invitee = invitee
    }

}
