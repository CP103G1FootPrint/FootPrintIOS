//
//  CreateTripViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/12.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class CreateTripViewController: UIViewController ,UIPickerViewDataSource,UIPickerViewDelegate{
    
    
    @IBOutlet weak var dayPicker: UITextField!
    @IBOutlet weak var datePickerTextFild: UITextField!
    @IBOutlet weak var tripNameTextFild: UITextField!
    let datePicker = UIDatePicker()
    var picker = UIPickerView()
    var days = ["1","2","3","4","5","6","7","8","9","10"]
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        picker.delegate = self
        picker.dataSource = self
        dayPicker.inputView = picker
         let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:Selector(("donePicker")))
        
        
    }
    func donePicker() {
        
        dayPicker.resignFirstResponder()
        
    }
    
    
    
    func createDatePicker(){
        datePicker.datePickerMode = .date
        datePickerTextFild.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
        
        toolbar.setItems([doneButton], animated: true)
        datePickerTextFild.inputAccessoryView = toolbar
    }
    @objc func doneClicked(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        datePickerTextFild.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    //PickerView有幾個區塊
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //裡面有幾列
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    
    //選擇到的那列要做的事
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dayPicker.text = days[row]
    }
    //設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return days[row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
