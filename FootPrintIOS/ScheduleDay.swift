class ScheduleDay : Codable {
    var type:String?
    var numberOfDay:Int?
    var messageType:String?
    var sender:String?
    var receiver:String?
    var controlNumber:Int?
    var tabCount:Int?
    var tripId:Int?
    var landMarkList:String?
    
    public init (_ type:String, _ numberOfDay:Int, _ messageType:String, _ sender:String, _ receiver:String, _ controlNumber: Int, _ tripId:Int){
        self.type = type
        self.numberOfDay = numberOfDay
        self.messageType = messageType
        self.sender = sender
        self.receiver = receiver
        self.controlNumber = controlNumber
        self.tripId = tripId
    }
    
    public init (_ type:String, _ numberOfDay:Int, _ messageType:String, _ sender:String, _ receiver:String, _ controlNumber: Int, _ tripId:Int, _ landMarkList:String){
        self.type = type
        self.numberOfDay = numberOfDay
        self.messageType = messageType
        self.sender = sender
        self.receiver = receiver
        self.controlNumber = controlNumber
        self.tripId = tripId
        self.landMarkList = landMarkList
    }
    
    public init (_ type:String, _ messageType:String, _ sender:String, _ receiver:String, _ controlNumber: Int, _ tabCount:Int){
        self.type = type
        self.messageType = messageType
        self.sender = sender
        self.receiver = receiver
        self.controlNumber = controlNumber
        self.tabCount = tabCount
    }
}
