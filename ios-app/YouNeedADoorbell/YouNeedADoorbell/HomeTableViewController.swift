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

class HomeTableViewController: UITableViewController {
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
    
    public func loadSampleData() {
        let region = Region(tz: .americaNewYork, cal: .gregorian, loc: .englishUnitedStates)
        let start = DateInRegion(absoluteDate: Date(), in: region)
        let start1 = start + 4.weeks
        let end1 = start1 + 5.hours
        let start2 = start + 39.hours
        let end2 = start2 + 2.hours
        self.addGathering(title: "Poker Night", detail: "555-555-1234", startDate: start1.absoluteDate, endDate: end1.absoluteDate)
        self.addGathering(title: "Gala Pregame", detail: "601-123-4589", startDate: start2.absoluteDate, endDate: end2.absoluteDate)
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
                let name = senderViewController.nameTextField.text
                let startDate = senderViewController.startDatePicker.date
                let endDate = senderViewController.endDatePicker.date
                let assignHosts = senderViewController.assignHostsSwitch.isOn
                let assignRandomly = senderViewController.assignRandomlySwitch.isOn
                
                // get item from voice picker
                let voicePicker = senderViewController.voicePicker
                let component = 0 // implementation detail
                let delegate = voicePicker!.delegate
                let row = voicePicker!.selectedRow(inComponent: component)
                let voice = delegate?.pickerView!(voicePicker!, titleForRow: row, forComponent: component)
                let voiceIdentifier = AVSpeechSynthesisVoice.fromColloquialIdentifier(identifier: voice!)
                print("new gathering")
                
                // initialize new gathering
                let doorbell = Doorbell(doorbellText: nil, voiceIdentifier: voiceIdentifier?.identifier, arrivalMessage: nil, assignmentMessage: nil)
                let gathering = Gathering(title: name, detail: nil, startDate: startDate, endDate: endDate, assignHosts: assignHosts, assignRandomly: assignRandomly, doorbell: doorbell)
                
                // add gathering to table
                self.addGathering(gathering: gathering)
            }
        }
    }
}
