//
//  PasscodeLockStateType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import UIKit

public protocol PasscodeLockStateType {
    
    var title				: String 	{get}
    var description			: String 	{get}
    var isCancellableAction	: Bool 		{get}
    var isTouchIDAllowed	: Bool 		{get}
	var tintColor			: UIColor? 	{get}
    
}
