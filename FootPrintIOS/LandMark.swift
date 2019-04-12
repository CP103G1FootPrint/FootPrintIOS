class LandMark: Codable  {
    var id : Int?
    var name : String?
    var address : String?
    var latitude : Double?
    var longitude : Double?
    var description : String?
    var openingHours: String?
    var openState : String?
    var type : String?
    
    var userID : Int?
    var imageID : Int?
    var timeStamp : String?
    var nickName : String?
    var account : String?
    var star : Double?
    
    public init(_ id: Int, _ name: String, _ address: String, _ latitude: Double, _ longitude: Double, _ description: String, _ openingHours: String, _ type: String) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.openingHours = openingHours
        self.type = type
    }
    
    public init(_ id: Int, _ name: String, _ address: String, _ latitude: Double, _ longitude: Double, _ description: String, _ openingHours: String, _ type: String, _ star: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.openingHours = openingHours
        self.type = type
        self.star = star
    }
    
    public init(_ account: String, _ imageID: Int, _ nickName: String) {
        self.account = account
        self.imageID = imageID
        self.nickName = nickName
    }
    
    public init(_ account: String, _ address: String, _ nickName: String) {
        self.account = account
        self.address = address
        self.nickName = nickName
    }
    
    public init(_ id: Int, _ address: String) {
        self.id = id
        self.address = address
    }
    
    public init(_ name: String, _ id: Int){
        self.id = id
        self.name = name
    }
}
