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

class GatheringsTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    
    // helper
    private var gatheringCellToEdit: Int? = nil
    
    private var gatherings = [Gathering]()
    
    public func addGathering(title: String?, detail: String?, startDate: Date?, endDate: Date?) {
        let gathering = Gathering(title: title, detail: detail, startDate: startDate, endDate: endDate)
        self.addGathering(gathering: gathering)
    }
    
    public func addGathering(gathering: Gathering?) {
        if let gathering = gathering {
            gatherings.append(gathering)
            tableView.reloadData()
        }
    }
    
    public func updateGathering(gathering: Gathering, atRow row: Int) {
        self.gatherings[row] = gathering
    }
    
    public func loadData() {
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }
        
        self.ref.child("users/\(user.uid)/gatherings").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let gatheringId = snapshot.key
            self.ref.child("gatherings/\(gatheringId)").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if let gatheringDict = snapshot.value as? Dictionary<String, String> {
                    self.addGathering(gathering: Gathering(withDict: gatheringDict))
                } else {
                    print("error: couldn't find gathering")
                    return
                }
            })
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        loadData()
        // loadSampleData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GatheringsTableViewCell else {
            fatalError("The dequeued cell is not an instance of HomeTableViewCell")
        }
        let gathering = gatherings[indexPath.row]
        
        // Configure the cell
        cell.titleLabel.text = gathering.title
        cell.contactLabel.text = gathering.detail
        cell.occursWhenLabel.text = gathering.starts_in
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.gatheringCellToEdit = indexPath.row
        performSegue(withIdentifier: "edit_existing_gathering", sender: self)
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
            let destinationViewController = segue.destination as! EditGatheringViewController
            if let row = self.gatheringCellToEdit {
                destinationViewController.thisGathering = self.gatherings[row]
            } else {
                // error
                print("error")
                return
            }
        }
    }
    
    @IBAction func unwindAddNewGatheringAction(unwindSegue: UIStoryboardSegue) {
        if let senderViewController = unwindSegue.source as? EditGatheringViewController {
            if unwindSegue.identifier == "save_gathering" {
                if let gathering = senderViewController.thisGathering {
                    if self.gatheringCellToEdit != nil {
                        let row = self.gatheringCellToEdit!
                        self.updateGathering(gathering: gathering, atRow: row)
                        self.gatheringCellToEdit = nil
                    } else {
                        self.addGathering(gathering: gathering)
                    }
                }
            }
        }
    }
}
