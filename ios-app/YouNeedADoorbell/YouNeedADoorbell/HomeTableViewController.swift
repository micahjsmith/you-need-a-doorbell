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
    
    public func addGathering(withTitle title: String?, andDetail detail: String?, andStartDate start: Date?, andEndDate end: Date?) {
        let item = Gathering(withTitle: title, andDetail: detail, andStartDate: start, andEndDate: end)
        gatherings.append(item)
        tableView.reloadData()
    }
    
    public func loadSampleGatherings() {
        let region = Region(tz: .americaNewYork, cal: .gregorian, loc: .englishUnitedStates)
        let start1 = DateInRegion(string: "2018-11-19T20:30:00", format: .iso8601Auto, fromRegion: region)
        let end1 = start1! + 4.hours
        let start2 = DateInRegion(string: "2018-01-30T19:00:00", format: .iso8601Auto, fromRegion: region)
        let end2 = start2! + 2.hours
        self.addGathering(withTitle: "Poker Night", andDetail: "555-555-1234", andStartDate: start1!.absoluteDate, andEndDate: end1.absoluteDate)
        self.addGathering(withTitle: "Gala Pregame", andDetail: "601-123-4589", andStartDate: start2!.absoluteDate, andEndDate: end2.absoluteDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleGatherings()
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
}
