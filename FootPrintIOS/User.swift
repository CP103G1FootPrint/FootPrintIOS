class User: Codable{
    var password : String?
    var nickname : String?
    var birthday : String?
    var constellation : String?
    var account : String?
    
    init(_ password:String,_ nickname:String,_ birthday:String,_ constellation:String,_ account:String) {
        self.password = password
        self.nickname = nickname
        self.birthday = birthday
        self.constellation = constellation
        self.account = account
    }
}

