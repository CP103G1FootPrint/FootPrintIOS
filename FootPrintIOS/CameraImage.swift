class CameraImage: Codable  {
    var imageID : Int?
    var description: String?
    var openState: String?
    var userID: String?
    var landMarkID: Int?
    
    public init(_ imageID: Int, _ description: String, _ openState: String, _ userID: String, _ landMarkID: Int) {
        self.imageID = imageID
        self.description = description
        self.openState = openState
        self.userID = userID
        self.landMarkID = landMarkID
    }
    
}
