class Account: Codable {
    var  account: String?
    var  password: String?
    var  nickname: String?
    var  birthday: String?
    var  constellation: String?
    var  integral: Int?
    var  fb:Int?
    
    public init(_ account: String, _ password: String, _ nickname: String, _ birthday: String, _ constellation: String, _ integral: Int, _ fb: Int) {
        self.account = account
        self.password = password
        self.nickname = nickname
        self.birthday = birthday
        self.constellation = constellation
        self.integral = integral
        self.fb = fb
    }
    
    public init (_ account: String, _ password: String){
        self.account = account
        self.password = password
    }
    
    public init(_ account: String, _ password: String, _ nickname: String, _ birthday: String, _ constellation: String) {
        self.account = account
        self.password = password
        self.nickname = nickname
        self.birthday = birthday
        self.constellation = constellation
    }
    
}
