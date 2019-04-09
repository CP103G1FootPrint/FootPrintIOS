//
//  Message.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/2.
//  Copyright © 2019 lulu. All rights reserved.
//
class Message:Codable{
    var chatId: Int?
    var type: String?
    var sender: String?
    var receiver: String?
    var content: String?
    var messageType: String?
    var timeStamp: String?
    
    public init(_ chatId:Int ,_ type: String, _ sender: String, _ receiver: String, _ content:String, _ messageType: String, _ timeStamp: String){
        self.chatId = chatId
        self.type = type
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.messageType = messageType
        self.timeStamp = timeStamp
    }
    public init(_ chatId:Int,_ sender: String, _ receiver: String, _ content:String,_ timeStamp: String){
        self.chatId = chatId
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.timeStamp = timeStamp
    }
    
    public init(_ type: String,_ sender: String, _ receiver: String, _ content: String, _ messageType: String) {
        self.type = type
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.messageType = messageType
    }
}
