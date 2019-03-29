
import UIKit

private let reuseIdentifier = "RecordCell"
class PersonalRecordVC: UICollectionViewController {
    
    let userDefault = UserDefaults.standard
    let url_server = URL(string: common_url + "Details")
    
    var animailImages = ["柴犬","柯基","啾啾","柴犬","柯基","啾啾","柴犬","柯基","啾啾"]
    let fullScreenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //下方為設定手機與照片的排序設定
        let layout = collectionView.collectionViewLayout as?    UICollectionViewFlowLayout
        let width = (UIScreen.main.bounds.width - 2 * 2) / 3
        layout?.itemSize = CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return animailImages.count //數字為照片數量
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let animal = animailImages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PersonalRecordCVCell
        //as! PhotoCollectionViewCell 轉型
        
        cell.RecordCellImage.image = UIImage(named: animal)//數字變字串
        
        return cell
    }
}
