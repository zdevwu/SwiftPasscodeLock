//
//  ConfirmPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

struct ConfirmPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let isCancellableAction = true
    var isTouchIDAllowed = false
    
    private var passcodeToConfirm: [String]
    
	init(passcode: [String], stringsToShow: StringsToBeDisplayed?) {
        
        passcodeToConfirm = passcode
        title = (stringsToShow?.PasscodeLockConfirmTitle ?? localizedStringFor("PasscodeLockConfirmTitle", comment: "Confirm passcode title"))
        description = (stringsToShow?.PasscodeLockConfirmDescription ?? localizedStringFor("PasscodeLockConfirmDescription", comment: "Confirm passcode description"))
    }
    
	func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?) {
        
        if passcode == passcodeToConfirm {
            
            lock.repository.savePasscode(passcode)
            lock.delegate?.passcodeLockDidSucceed(lock)
        
        } else {
            
            let mismatchTitle = (stringsToShow?.PasscodeLockMismatchTitle ?? localizedStringFor("PasscodeLockMismatchTitle", comment: "Passcode mismatch title"))
            let mismatchDescription = (stringsToShow?.PasscodeLockMismatchDescription ?? localizedStringFor("PasscodeLockMismatchDescription", comment: "Passcode mismatch description"))
            
            let nextState = SetPasscodeState(title: mismatchTitle, description: mismatchDescription)
            
            lock.changeStateTo(nextState)
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
}
