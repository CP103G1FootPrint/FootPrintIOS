import Foundation

class Record: Codable {
    var imageID: Int
    
    public init(_ imageID: Int) {
        self.imageID = imageID
    }
}
