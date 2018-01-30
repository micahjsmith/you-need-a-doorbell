//
//  FirstViewController.swift
//  YouNeedADoorbell
//
//  Created by Micah Smith on 1/29/18.
//  Copyright © 2018 Micah Smith. All rights reserved.
//

import UIKit
import SwiftDate

class HomeTableViewController: UITableViewController {
    private var gatherings = [Gathering]()
    
    public func addGathering(title: String?, detail: String?, startDate: Date?, endDate: Date?) {
        let item = Gathering(title: title, detail: detail, startDate: startDate, endDate: endDate)
        gatherings.append(item)
        tableView.reloadData()
    }
    
    public func loadSampleData() {
        let region = Region(tz: .americaNewYork, cal: .gregorian, loc: .englishUnitedStates)
        let start = DateInRegion(absoluteDate: Date(), in: region)
        let end1 = start + 4.weeks
        let end2 = start + 39.hours
        self.addGathering(title: "Poker Night", detail: "555-555-1234", startDate: start.absoluteDate, endDate: end1.absoluteDate)
        self.addGathering(title: "Gala Pregame", detail: "601-123-4589", startDate: start.absoluteDate, endDate: end2.absoluteDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gatherings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Pop a cell
        let cellIdentifier = "HomeTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeTableViewCell else {
            fatalError("The dequeued cell is not an instance of HomeTableViewCell")
        }
        let gathering = gatherings[indexPath.row]
        
        // Configure the cell
        cell.titleLabel.text = gathering.title
        cell.contactLabel.text = gathering.detail
        cell.occursWhenLabel.text = gathering.starts_in
        
        return cell
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
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    @IBAction func unwindAddNewGatheringAction(unwindSegue: UIStoryboardSegue) {
        if unwindSegue.source is AddNewGatheringTableViewController {
            if let senderViewController = unwindSegue.source as? AddNewGatheringTableViewController {
                let name = senderViewController.nameTextField
                print("new gathering")
                print("name: \(name)")
            }
        }
    }
}
