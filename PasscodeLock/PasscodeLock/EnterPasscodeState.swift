//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title				: String
    let description			: String
    let isCancellableAction	: Bool
    var isTouchIDAllowed 	= true
	var tintColor			: UIColor?
	var font				: UIFont?
    
    private var inccorectPasscodeAttempts = 0
    
	init(allowCancellation: Bool = false, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

		let defaultColor = defaultCustomColor()
        self.isCancellableAction = allowCancellation
        self.title = (stringsToShow?.passcodeLockEnterTitle ?? localizedStringFor("PasscodeLockEnterTitle", comment: "Enter passcode title"))
        self.description = (stringsToShow?.passcodeLockEnterDescription ?? localizedStringFor("PasscodeLockEnterDescription", comment: "Enter passcode description"))
		self.tintColor = (tintColor ?? defaultColor)
		self.font = (font ?? UIFont.systemFontOfSize(16))
    }
    
	mutating func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
        guard let currentPasscode = lock.repository.passcode else {
            return
        }
        
        if (passcode == currentPasscode) {
            lock.delegate?.passcodeLockDidSucceed(lock)
            
        } else {
            
            inccorectPasscodeAttempts += 1
            if (inccorectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts) {
                postNotification()
            }
            
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
    
    private mutating func postNotification() {

        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(PasscodeLockIncorrectPasscodeNotification, object: nil)
    }
}
