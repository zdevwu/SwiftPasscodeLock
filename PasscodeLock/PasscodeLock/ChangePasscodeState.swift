//
//  ChangePasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import UIKit

struct ChangePasscodeState: PasscodeLockStateType {
    
    let title				: String
    let description			: String
    let isCancellableAction = true
    var isTouchIDAllowed 	= false
	var tintColor 			: UIColor?
	var font				: UIFont?

	init(stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {


		let defaultColor = defaultCustomColor()
        self.title = (stringsToShow?.passcodeLockChangeTitle ?? localizedStringFor("PasscodeLockChangeTitle", comment: "Change passcode title"))
        self.description = (stringsToShow?.passcodeLockChangeDescription ?? localizedStringFor("PasscodeLockChangeDescription", comment: "Change passcode description"))
		self.tintColor = (tintColor ?? defaultColor)
		self.font = (font ?? UIFont.systemFont(ofSize: 16))
    }
}
