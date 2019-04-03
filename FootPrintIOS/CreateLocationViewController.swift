import UIKit

class CreateLocationViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    

    @IBOutlet weak var nameUITextField: UITextField!
    @IBOutlet weak var addressUITextField: UITextField!
    @IBOutlet weak var descriptionUITextField: UITextField!
    @IBOutlet weak var openHoursUITextView: UITextView!
    @IBOutlet weak var evaluationUITextView: UITextView!
    @IBOutlet weak var typeUITextView: UITextView!
    @IBOutlet weak var openHorsEndUITextView: UITextView!
    
    
    let openHoursPicker = UIDatePicker()
    var picker = UIPickerView()
    var types = ["Recommended by Tourist","Restaurant","Hotel","Spot"]
    let format = DateFormatter()
    var chooseType: String = ""
    var chooseOpenHoursStand: String = ""
    var chooseOpenHoursEnd: String = ""
    var resultCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //textViewColor
        textViewColor(textView: openHoursUITextView)
        textViewColor(textView: openHorsEndUITextView)
        
        //openHour挑選器
        createDatePickerStart()
        createDatePickerEnd()
        
        //type挑選器
        picker.dataSource = self
        picker.delegate = self
        typeUITextView.text = types[0]
        typeUITextView.inputView = picker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        typeUITextView.inputAccessoryView = toolBar

    }
    
    @objc func donePicker(){
        typeUITextView.resignFirstResponder()
    }
    @objc func cancelClick(){
        typeUITextView.resignFirstResponder()
    }
    
    @IBAction func evaluationSender(_ sender: Any) {
    }
    @IBAction func createLandMarkButton(_ sender: Any) {
    }
    
    //PickerView有幾個區塊
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //裡面有幾列
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    //選擇到的那列要做的事
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeUITextView.text = types[row]
        chooseType = types[row]
    }
    //設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    //框顏色
    func textViewColor(textView:UITextView){
        //        textView.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
    }
    
    //選擇開放時間Start
    func createDatePickerStart(){
        openHoursPicker.datePickerMode = .time
        openHoursUITextView.inputView = openHoursPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedStart))
        toolbar.setItems([doneButton], animated: true)
        openHoursUITextView.inputAccessoryView = toolbar
    }
    @objc func doneClickedStart(){
        format.dateFormat = "HH"
//        let date = format.date(from: openHoursPicker.date)
        let Date24 = format.string(from: openHoursPicker.date)
        openHoursUITextView.text = Date24
//        openHoursUITextView.text = format.string(from: openHoursPicker.date)
        chooseOpenHoursStand = Date24
        self.view.endEditing(true)
    }
    
    //選擇開放時間End
    func createDatePickerEnd(){
        openHoursPicker.datePickerMode = .time
        openHorsEndUITextView.inputView = openHoursPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedEnd))
        toolbar.setItems([doneButton], animated: true)
        openHorsEndUITextView.inputAccessoryView = toolbar
    }
    @objc func doneClickedEnd(){
        format.dateFormat = "HH"
        //        let date = format.date(from: openHoursPicker.date)
        let Date24 = format.string(from: openHoursPicker.date)
        openHorsEndUITextView.text = Date24
        //        openHoursUITextView.text = format.string(from: openHoursPicker.date)
        chooseOpenHoursEnd = Date24
        self.view.endEditing(true)
    }
}
