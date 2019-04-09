class User: Codable{
    var password : String?
    var nickname : String?
    var birthday : String?
    var constellation : String?
    var account : String?
    var integral : Int?
    
    //修改頁用
    init(_ password:String,_ nickname:String,_ birthday:String,_ constellation:String,_ account:String) {
        self.password = password
        self.nickname = nickname
        self.birthday = birthday
        self.constellation = constellation
        self.account = account
    }
    //取值頁
    init(_ password:String,_ nickname:String,_ birthday:String,_ constellation:String,_ integral:Int) {
        self.password = password
        self.nickname = nickname
        self.birthday = birthday
        self.constellation = constellation
        self.integral = integral
    }
    
    
}

