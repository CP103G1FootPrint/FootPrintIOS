//
//  AddFriendListTableViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/16.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit




class AddFriendListTableViewController: UITableViewController {
//    let allItems = [Items]()
//    var selectedItems = [Items]()
    
//    var coureSelect:[String:String]!
//    var delegate : CreateTripViewController
    let url_server = URL(string: common_url + "/TripServlet")

    var friendArray: [String] = Array()
    override func viewDidLoad() {
        super.viewDidLoad()
        friendArray.append("Tom")
        friendArray.append("Vivian")
        friendArray.append("Sandy")
        friendArray.append("May")

        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendArray.count
    }

    //設定cell要顯示的內容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendListTableViewCell
        cell.friendNameLabel.text = friendArray[indexPath.row]
        
        cell.checkboxButton.addTarget(self, action: #selector(clickCheckbox(sender:)), for: .touchUpInside)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        friendArray.items[indexPath.row].isSelected = true
    }
    
    
    
    
    
    
    
    @objc func clickCheckbox (sender : UIButton){
        print("button pressed")
        if sender.isSelected{
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
        
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let indexPath = tableView.indexPathForSelectedRow
//        let currentCell = tableView.cellForRow(at: indexPath) as! AddFriendListTableViewCell
//        let currentItem = currentCell.friendNameLabel!.text
//        let alertController = UIAlertController(title: "Invite friends", message: "You Selected " + currentItem! , preferredStyle: .alert)
//        let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
//        alertController.addAction(defaultAction)
//
//        present(alertController, animated: true, completion: nil)
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFriendDetail"{
        let controller = segue.destination as? CreateTripViewController
        if let selectRow = tableView.indexPathForSelectedRow?.row{
            controller?.friendListTextView.text = friendArray[selectRow]
        }
//        controller?.coureSelect = self.coureSelect
        }
    
    }
    
//    @IBAction func doneButtonPressed(_ sender: Any) {
//
//        self.navigationController?.popViewController(animated: true)
//    }
    
}
