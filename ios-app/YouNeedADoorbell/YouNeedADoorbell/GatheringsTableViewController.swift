//
//  FirstViewController.swift
//  YouNeedADoorbell
//
//  Created by Micah Smith on 1/29/18.
//  Copyright © 2018 Micah Smith. All rights reserved.
//

import UIKit
import SwiftDate
import AVFoundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseUI

class GatheringsTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var dm: DatabaseManager!
    
    // table
    var dataSource: FUITableViewDataSource?
    
    // helpers
    public func getUid() -> String {
        return (Auth.auth().currentUser?.uid)!
    }
    
    public func getQuery() -> DatabaseQuery {
        let query: DatabaseQuery = self.ref.child("users/\(getUid())/gatherings").queryOrdered(byChild: "startDate")
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        dm = DatabaseManager()
        
        self.dataSource = self.tableView.bind(to: getQuery()) { tableView, indexPath, snapshot in
            // Dequeue cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "gatheringsTableViewCell", for: indexPath) as! GatheringsTableViewCell
            
            /* populate cell */
            guard let gathering = Gathering(snapshot: snapshot) else { return cell }
            cell.titleLabel?.text = gathering.title
            cell.detailLabel?.text = gathering.detail
            cell.occursWhenLabel?.text = gathering.occursWhen
            return cell
        }
        
        self.tableView.dataSource = self.dataSource
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "edit_existing_gathering", sender: indexPath)
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
    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_existing_gathering" {
            guard let indexPath: IndexPath = sender as? IndexPath else { return }
            guard let destinationViewController = segue.destination as? GatheringDetailViewController else {
                return
            }
            if let dataSource = self.dataSource {
                destinationViewController.gatheringKey = dataSource.snapshot(at: indexPath.row).key
            }
        }
    }
    
    @IBAction func unwindFromSaveGatheringsDetail(_ segue: UIStoryboardSegue) {
        print("in unwindFromSaveGatheringsDetail")
    }
}
