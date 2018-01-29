//
//  Model.swift
//  YouNeedADoorbell
//
//  Created by Micah Smith on 1/29/18.
//  Copyright © 2018 Micah Smith. All rights reserved.
//

import Foundation
import SwiftDate

class Gathering {
    var title: String?
    var detail: String?
    var start: Date?
    var end: Date?
    
    var starts_in: String? {
        get {
            let now = DateInRegion()
            let (colloquial, _) = try! now.absoluteDate.colloquial(to: start!)
            return colloquial
        }
    }
    
    public init(withTitle title: String?, andDetail detail: String?, andStartDate start: Date?, andEndDate end: Date?) {
        self.title = title
        self.detail = detail
        self.start = start
        self.end = end
    }
}

