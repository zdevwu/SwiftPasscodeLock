//
//  ChangePasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

struct ChangePasscodeState: PasscodeLockStateType {
    
    let title				: String
    let description			: String
    let isCancellableAction = true
    var isTouchIDAllowed 	= false
	var tintColor 			: UIColor?

	init(stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?) {

		let defaultColor = UIColor(red: 0, green: 100/255, blue: 165/255, alpha: 1)
        self.title = (stringsToShow?.passcodeLockChangeTitle ?? localizedStringFor("PasscodeLockChangeTitle", comment: "Change passcode title"))
        self.description = (stringsToShow?.passcodeLockChangeDescription ?? localizedStringFor("PasscodeLockChangeDescription", comment: "Change passcode description"))
		self.tintColor = (tintColor ?? defaultColor)
    }
    
	func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?) {
        
        guard let currentPasscode = lock.repository.passcode else {
            return
        }
        
        if (passcode == currentPasscode) {
			let nextState = SetPasscodeState(stringsToShow: stringsToShow, tintColor: tintColor)
            lock.changeStateTo(nextState)
            
        } else {
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
}
