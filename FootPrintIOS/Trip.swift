class Trip: Codable {
    var tripID: Int
    var title: String
    var date: String
    var type : String
    var days : Int
    
    
    public init(_ tripID:Int,_ title:String,_ date :String,_ type:String,_ days:Int){
        self.tripID = tripID
        self.title = title
        self.date = date
        self.type = type
        self.days = days
        
    }
    
    
}
