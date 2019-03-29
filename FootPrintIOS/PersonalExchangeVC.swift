import UIKit

class PersonalExchangeVC: UIViewController,UITableViewDataSource,UICollectionViewDelegate{
    
    @IBOutlet weak var exchangeTBV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? PersonalQRcode
        let indexPath = self.exchangeTBV.indexPathForSelectedRow
        controller?.productName = exchangeGoods[indexPath!.row].productName
        
    }
    
    var exchangeGoods : [ExchangeGoods] = [ExchangeGoods ("","iphoneSE","原場 64G 銀色","300")]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchangeGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "exchangeCell", for: indexPath) as? ExchangeTVCell else {
            return UITableViewCell()
        }
        cell.productPic.image = UIImage(named: exchangeGoods[indexPath.row].productPic)
        cell.productName.text = exchangeGoods[indexPath.row].productName
        cell.productScr.text = exchangeGoods[indexPath.row].productScr
        cell.integral.text = exchangeGoods[indexPath.row].integral
        return cell
    }
}
