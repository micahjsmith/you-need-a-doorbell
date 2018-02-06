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

class DatabaseManager {
    var ref: DatabaseReference!
    
    public init() {
        ref = Database.database().reference()
    }
    
    public func getUserUid() -> String {
        return (Auth.auth().currentUser?.uid)!
    }
    
    public func readGathering(withKey key: String, completion: @escaping (Gathering?) -> ()) {
        ref.child("/gatherings/\(key)").observeSingleEvent(of: .value) { (snapshot) in
            let gathering = Gathering(snapshot: snapshot)
            completion(gathering)
        }
    }
    
    public func writeGathering(_ gathering: Gathering) {
        self.writeGathering(gathering, forUser: getUserUid())
    }
    
    public func writeGathering(_ gathering: Gathering, forUser userId: String) {
        let key = ref.child("/gatherings").childByAutoId().key
        var data = gathering.asDict
        data["userId"] = userId
        let updates = [
            "/gatherings/\(key)": data,
            "/users/\(userId)/gatherings/\(key)": true,
            ] as [String : Any]
        ref.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("error adding data")
                print(error)
            }
        }
    }
    
    public func updateGathering(_ gathering: Gathering) {
        if let key = gathering.uid {
            var data = gathering.asDict
            data["userId"] = getUserUid()
            ref.child("/gatherings/\(key)").setValue(data)
        } else {
            print("error: wasn't able to update gathering")
        }
    }
    
    public func deleteGathering(_ gathering: Gathering) {
        if let key = gathering.uid {
            let updates = [
                "/users/\(getUserUid())/gatherings/\(key)": NSNull(),
                "/gatherings/\(key)": NSNull(),
            ] as [String : Any]
            ref.updateChildValues(updates)
        }
    }

}

class SampleDataManager : DatabaseManager {
    
    
    public func dropDatabase() {
        ref.removeValue()
    }
    
   
    
    public func loadSampleData() {
        let region = Region(tz: .americaNewYork, cal: .gregorian, loc: .englishUnitedStates)
        let start = DateInRegion(absoluteDate: Date(), in: region)
        
        // create first sample gathering
        let title1 = "Poker Night"
        let contact1 = "5555551234"
        let start1 = start + 4.weeks
        let end1 = start1 + 5.hours
        let gathering1 = Gathering(title: title1, contact: contact1, startDate: start1.absoluteDate, endDate: end1.absoluteDate)
        
        // create second sample gathering
        let title2 = "Gala Pregame"
        let contact2 = "6011234589"
        let start2 = start + 39.hours
        let end2 = start2 + 2.hours
        let gathering2 = Gathering(title: title2, contact: contact2, startDate: start2.absoluteDate, endDate: end2.absoluteDate)
        
        for gathering in [gathering1, gathering2] {
            self.writeGathering(gathering)
        }
        
        // create third sample gathering, for a different user
        let title3 = "Secret party"
        let contact3 = "1238066589"
        let start3 = start + 77.hours
        let end3 = start3 + 2.hours
        let gathering3 = Gathering(title: title3, contact: contact3, startDate: start3.absoluteDate, endDate: end3.absoluteDate)
        self.writeGathering(gathering3, forUser: "fakeUserId")
        
        return
    }
}
