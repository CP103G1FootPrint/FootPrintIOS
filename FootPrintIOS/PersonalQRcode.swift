import UIKit

class PersonalQRcode: UIViewController {
    
    var productName : String?
    
    
    
    
    
    @IBOutlet weak var lbproductName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbproductName.text = productName!
        lbproductName.clipsToBounds = true
        lbproductName.layer.cornerRadius = 13
    }
    
    
}
