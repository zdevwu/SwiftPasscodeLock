//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import UIKit

public let PasscodeLockIncorrectPasscodeNotification = NSNotification.Name("passcode.lock.incorrect.passcode.notification")

struct EnterPasscodeState: PasscodeLockStateType {

    let title: String
    let description: String
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    var tintColor: UIColor?
    var font: UIFont?

    var inccorectPasscodeAttempts : Int = 0

    init(allowCancellation: Bool = false, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

        let defaultColor = defaultCustomColor()
        self.isCancellableAction = allowCancellation
        self.title = (stringsToShow?.passcodeLockEnterTitle ?? localizedStringFor("PasscodeLockEnterTitle", comment: "Enter passcode title"))
        self.description = (stringsToShow?.passcodeLockEnterDescription ?? localizedStringFor("PasscodeLockEnterDescription", comment: "Enter passcode description"))
        self.tintColor = (tintColor ?? defaultColor)
        self.font = (font ?? UIFont.systemFont(ofSize: 16))
    }

    mutating func postNotification() {

        let center = NotificationCenter.default
        center.post(name: PasscodeLockIncorrectPasscodeNotification, object: nil)
    }
}
