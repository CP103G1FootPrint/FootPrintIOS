class Trip: Codable {
   

    var tripID: Int
    var title: String
    var date: String
    var type : String
    
    
    public init(_ tripID:Int,_ title:String,_ date :String,_ type:String){
        self.tripID = tripID
        self.title = title
        self.date = date
        self.type = type
        
    }
    
    
}
