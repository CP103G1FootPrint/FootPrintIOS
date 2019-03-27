class GroupAlbum: Codable {
    var albumID : Int
    var tripID : Int
    
    public init(_ albumID: Int, _ tripID: Int) {
        self.albumID = albumID
        self.tripID = tripID
    }
}
