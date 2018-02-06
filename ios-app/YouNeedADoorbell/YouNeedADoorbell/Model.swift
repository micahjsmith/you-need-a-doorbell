//
//  Model.swift
//  YouNeedADoorbell
//
//  Created by Micah Smith on 1/29/18.
//  Copyright © 2018 Micah Smith. All rights reserved.
//

import Foundation
import SwiftDate
import AVFoundation
import FirebaseDatabase
import PhoneNumberKit

class Gathering {
    static let DEFAULT_CONTACT = "(555) 555-1234"
    
    public var uid: String?
    
    var title: String?
    var contact: String?
    var start: Date?
    var end: Date?
    
    // MARK: - doorbell configuration
    var assignHosts: Bool
    var assignRandomly: Bool
    var doorbell: Doorbell
    
    // MARK: - customizing guest list
    // TODO - consider changing to CNContact
    var hosts: [String] = []
    var approvedGuestList: [String] = []
    var blockedList: [String] = []
    
    // MARK: - computed properties
    var occursWhen: String? {
        get {
            let now = DateInRegion()
            let (colloquial, _) = try! start!.colloquial(to: now.absoluteDate)
            return colloquial
        }
    }
    
    var asDict: [String: Any] {
        get {
            return [
                "title": self.title!,
                "contact": self.contact ?? "",
                "startDate": self.start!.string(format: .iso8601Auto),
                "endDate": self.end!.string(format: .iso8601Auto),
                "assignHosts": self.assignHosts,
                "assignRandomly": self.assignRandomly,
                "doorbell": self.doorbell.asDict,
            ]
        }
    }
    
    public convenience init() {
        self.init(title: nil, contact: nil, startDate: nil, endDate: nil)
    }
    
    public convenience init(fromDict gathering: Dictionary<String, Any>) {
        let title = gathering["title"] as! String
        let contact = gathering["contact"] as! String
        let startDateString = gathering["startDate"] as! String
        // TODO this could be a bug
        let startDate = DateInRegion(string: startDateString, format: DateFormat.iso8601Auto, fromRegion: Region.Local())?.absoluteDate
        let endDateString = gathering["endDate"] as! String
        let endDate = DateInRegion(string: endDateString, format: DateFormat.iso8601Auto, fromRegion: Region.Local())?.absoluteDate
        let assignHosts = gathering["assignHosts"] as! Bool
        let assignRandomly = gathering["assignRandomly"] as! Bool
        let doorbell = Doorbell(fromDict: gathering["doorbell"] as! Dictionary<String, String>)
        self.init(title: title,
                  contact: contact,
                  startDate: startDate,
                  endDate: endDate,
                  assignHosts: assignHosts,
                  assignRandomly: assignRandomly,
                  doorbell: doorbell)
    }
    
    public convenience init?(snapshot: DataSnapshot) {
        let uid = snapshot.key
        guard let gatheringDict = snapshot.value as? Dictionary<String, Any> else { return nil }
        self.init(fromDict: gatheringDict)
        self.uid = uid
    }
    
    public init(title: String?,
                contact: String?,
                startDate: Date?,
                endDate: Date?,
                assignHosts: Bool = false,
                assignRandomly: Bool = false,
                doorbell: Doorbell? = nil) {
        self.title = title
        
        // TODO clean up
        if let contact = contact {
            self.contact = PhoneNumberKit.simpleFormat(contact)
        }
        
        self.start = startDate
        self.end = endDate
        
        self.assignHosts = assignHosts
        self.assignRandomly = assignRandomly
        
        if let doorbell = doorbell {
            self.doorbell = doorbell
        } else {
            self.doorbell = Doorbell()
        }
    }
}

class Doorbell {
    // todo get from somewhere else
    static let DEFAULT_DOORBELL_TEXT = "DING DONG!"
    static let DEFAULT_ARRIVAL_MESSAGE = "Guest {} has arrived to the party."
    static let DEFAULT_ASSIGNMENT_MESSAGE = "Please, {}, open the door."
    static let GUEST_PLACEHOLDER = "{}"
    
    
    var doorbellText: String
    var voice: AVSpeechSynthesisVoice
    var arrivalMessage: String
    var assignmentMessage: String
    
    var asDict: Dictionary<String, String> {
        get {
            return [
                "doorbellText": self.doorbellText,
                "voiceIdentifier": self.voice.identifier,
                "arrivalMessage": self.arrivalMessage,
                "assignmentMessage": self.assignmentMessage,
            ]
        }
    }
    
    public convenience init() {
        self.init(doorbellText: nil, voiceIdentifier: nil, arrivalMessage: nil, assignmentMessage: nil)
    }
    
    public convenience init(voiceIdentifier identifier: String) {
        self.init(doorbellText: nil, voiceIdentifier: identifier, arrivalMessage: nil, assignmentMessage: nil)
    }
    
    public convenience init(fromDict dict: Dictionary<String, String>) {
        let doorbellText = dict["doorbellText"]
        let identifier = dict["voiceIdentifier"]
        let arrivalMessage = dict["arrivalMessage"]
        let assignmentMessage = dict["assignmentMessage"]
        self.init(doorbellText: doorbellText,
                  voiceIdentifier: identifier,
                  arrivalMessage: arrivalMessage,
                  assignmentMessage: assignmentMessage)
    }
    
    
    public init(doorbellText: String?, voiceIdentifier: String?, arrivalMessage: String?, assignmentMessage: String?) {
        self.doorbellText = doorbellText ?? Doorbell.DEFAULT_DOORBELL_TEXT
        
        // careful with missings
        if let voiceIdentifier = voiceIdentifier {
            self.voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)!
        } else {
            self.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())!
        }
        
        self.arrivalMessage = arrivalMessage ?? Doorbell.DEFAULT_ARRIVAL_MESSAGE
        self.assignmentMessage = assignmentMessage ?? Doorbell.DEFAULT_ASSIGNMENT_MESSAGE
    }
    
    func announceArrival(guest: String?) {
        let string = self.doorbellText + " " + self.arrivalMessage.replacingOccurrences(of: Doorbell.GUEST_PLACEHOLDER, with: guest ?? "Someone")
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = self.voice
        synthesizer.speak(utterance)
    }
}
