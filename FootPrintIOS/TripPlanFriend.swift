class TripPlanFriend: Codable {
    
    var createID: String
    var invitee: String
    var tripId: Int
    
    public init(_ createID:String,_ invitee:String,_ tripId :Int){
        self.createID = createID
        self.invitee = invitee
        self.tripId = tripId
        
    }
    
    
}
