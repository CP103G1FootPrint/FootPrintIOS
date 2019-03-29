
import Foundation

class ExchangeGoods: Codable{
    var productPic = ""
    var productName = ""
    var productScr = ""
    var integral = ""
    
    init(_ productPic:String,_ productName:String,_ productScr:String,_ integral:String) {
        self.productPic = productPic
        self.productName = productName
        self.productScr = productScr
        self.integral = integral
    }
}
