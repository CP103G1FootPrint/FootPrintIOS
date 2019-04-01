class CreateTripFriends: Codable {
    
    var friendsId: Int?
    var inviter: String?
    var invitee: String?
    
    public init(_ friendsId:Int,_ inviter:String,_ invitee :String){
        self.friendsId = friendsId
        self.inviter = inviter
        self.invitee = invitee
        
    }
    
    
}
