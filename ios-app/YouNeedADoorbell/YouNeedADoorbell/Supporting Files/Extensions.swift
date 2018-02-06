//
//  Extensions.swift
//  YouNeedADoorbell
//
//  Created by Micah Smith on 2/5/18.
//  Copyright © 2018 Micah Smith. All rights reserved.
//

import Foundation
import AVFoundation
import PhoneNumberKit

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

extension AVSpeechSynthesisVoice {
    var colloquialIdentifier: String {
        get {
            return "\(self.name) (\(self.language))"
        }
    }
    
    static func getIdentifier(fromColloquialIdentifier colloquialIdentifier: String) -> String? {
        return AVSpeechSynthesisVoice.fromColloquialIdentifier(identifier: colloquialIdentifier)?.identifier
    }
    
    static func fromColloquialIdentifier(identifier: String) -> AVSpeechSynthesisVoice? {
        // elaborate way to do string pattern matching :(
        guard let firstLeftParenthesisIndex = identifier.index(of: "(") else {
            // error
            print("error: couldn't parse colloquial identifier for '\(identifier)'")
            return nil
        }
        let endOfNameIndex = identifier.index(before: firstLeftParenthesisIndex)
        let beginningOfLanguageIndex = identifier.index(after: firstLeftParenthesisIndex)
        let endOfLanguageEnd = identifier.index(before: identifier.endIndex)
        let name = identifier[..<endOfNameIndex]
        let language = identifier[beginningOfLanguageIndex..<endOfLanguageEnd]
        
        // elaborate way to find matches in array :(
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            if voice.name == name && voice.language == language {
                return voice
            }
        }
        
        // error
        print("error: couldn't find voice for name '\(name)' and language '\(language)'")
        return nil
    }
}

extension PhoneNumberKit {
    static func simpleFormat(_ numberString: String) -> String? {
        do {
            let phoneNumberKit = PhoneNumberKit()
            // TODO get correct region
            let phoneNumber = try phoneNumberKit.parse(numberString, withRegion: PartialFormatter().currentRegion, ignoreType: true)
            let phoneNumberFormatted = phoneNumberKit.format(phoneNumber, toType: .e164)
            return phoneNumberFormatted
        }
        catch {
            print("Generic parser error: \(error)")
            return nil
        }
    }
}
