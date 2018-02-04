//
//  DatabaseUtils.swift
//  YouNeedADoorbell
//
//  Created by Micah Smith on 2/3/18.
//  Copyright © 2018 Micah Smith. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftDate
import FirebaseAuth

class DataManager {
    var ref: FIRDatabaseReference!
    
    public init() {
        ref = FIRDatabase.database().reference()
    }
    
    public func writeGathering(_ gathering: Gathering) {
        // add gatherings to
        // - users/gatherings/id
        // - gatherings/id/
        guard let user = FIRAuth.auth()?.currentUser else {
            print("error: couldn't load user")
            return
        }
        
        let key = ref.child("gatherings").childByAutoId().key
        let updates = [
            "/gatherings/\(key)": gathering.as_dict,
            "/users/\(user.uid)/gatherings/\(key)": true,
            ] as [String : Any]
        ref.updateChildValues(updates) { (error, _) in
            print("error adding sample data")
        }
    }
    
    public func updateGathering(_ gathering: Gathering) {
        if let key = gathering.uid {
            ref.child("/gatherings/\(key)").setValue(gathering.as_dict)
        }
    }
    
    public func deleteGathering(_ gathering: Gathering) {
        guard let user = FIRAuth.auth()?.currentUser else {
            print("error: couldn't load user")
            return
        }
        
        if let key = gathering.uid {
            let updates = [
                "/gatherings/\(key)": NSNull(),
                "/users/\(user.uid)/gatherings/\(key)": NSNull(),
                ] as [String : Any]
            ref.updateChildValues(updates)
        }
    }

}

class SampleDataManager : DataManager {
    
    
    public func dropDatabase() {
        ref.removeValue()
    }
    
   
    
    public func loadSampleData() {
        let region = Region(tz: .americaNewYork, cal: .gregorian, loc: .englishUnitedStates)
        let start = DateInRegion(absoluteDate: Date(), in: region)
        
        // create first sample gathering
        let title1 = "Poker Night"
        let detail1 = "555-555-1234"
        let start1 = start + 4.weeks
        let end1 = start1 + 5.hours
        let gathering1 = Gathering(title: title1, detail: detail1, startDate: start1.absoluteDate, endDate: end1.absoluteDate)
        
        // create second sample gathering
        let title2 = "Gala Pregame"
        let detail2 = "601-123-4589"
        let start2 = start + 39.hours
        let end2 = start2 + 2.hours
        let gathering2 = Gathering(title: title2, detail: detail2, startDate: start2.absoluteDate, endDate: end2.absoluteDate)
        
        for gathering in [gathering1, gathering2] {
            self.writeGathering(gathering)
        }
        
        return
    }
}
