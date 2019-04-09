//
//  FindLocationTableViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/5.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class FindLocationTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    //假資料
    var allLandMark : [LandMark]?
//    var nearLocationss = [LandMark("A1","柴犬","柴犬"),LandMark("B","柯基","柯基")]
    var location : [LandMark]?
    
    func updateSearchResults(for searchController: UISearchController) {
        findAllLocationInfo(searchController)
//        if let searchText = searchController.searchBar.text {
//            location = allLandMark!.filter({ (string) -> Bool in
//                return string.type == searchText
//            })
//            tableView.reloadData()
//        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return location?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindLocationCell", for: indexPath)

        let lo = location![indexPath.row]
        cell.textLabel?.text = lo.account
        return cell
    }
    
    //取得所有地標
    func findAllLocationInfo(_ searchController:UISearchController) {
        let url_server = URL(string: common_url + "/LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "All"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    //                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.allLandMark = result
                        DispatchQueue.main.async {
                            if let searchText = searchController.searchBar.text {
                                self.location = self.allLandMark!.filter({ (string) -> Bool in
                                    return string.type == searchText
                                })
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
