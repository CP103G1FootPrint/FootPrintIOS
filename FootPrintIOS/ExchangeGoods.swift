
import Foundation

class ExchangeGoods: Codable{
    var id : Int
    var productId = ""
    var description = ""
    var point = ""
    
    init(_ id:Int,_ productId:String,_ description:String,_ point:String) {
        //        self.productPic = productPic
        self.id = id
        self.productId = productId
        self.description = description
        self.point = point
    }
}
