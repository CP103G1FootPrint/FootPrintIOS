class ChatMessage: Codable {
    var chatId: Int
    var userId: String
    var message: String
    var tripId: Int
    
    init(_ chatId: Int, _ userId: String, _ message: String, _ tripId: Int ) {
        self.chatId = chatId
        self.userId = userId
        self.message = message
        self.tripId = tripId
    }
    
}
