//
//  SetPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

struct SetPasscodeState: PasscodeLockStateType {
    
    let title				: String
    let description			: String
    let isCancellableAction = true
    var isTouchIDAllowed 	= false
	var tintColor			: UIColor?
    
	init(title: String, description: String, tintColor: UIColor?) {

		let defaultColor = UIColor(red: 0, green: 100/255, blue: 165/255, alpha: 1)
        self.title = title
        self.description = description
		self.tintColor = (tintColor ?? defaultColor)
    }

	init(stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?) {

		let defaultColor = UIColor(red: 0, green: 100/255, blue: 165/255, alpha: 1)
        self.title = (stringsToShow?.passcodeLockSetTitle ?? localizedStringFor("PasscodeLockSetTitle", comment: "Set passcode title"))
        self.description = (stringsToShow?.passcodeLockSetDescription ?? localizedStringFor("PasscodeLockSetDescription", comment: "Set passcode description"))
		self.tintColor = (tintColor ?? defaultColor)
    }
    
	func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?) {
        
		let nextState = ConfirmPasscodeState(passcode: passcode, stringsToShow: stringsToShow, tintColor: tintColor)
        lock.changeStateTo(nextState)
    }
}
