//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit

public class PasscodeLock: PasscodeLockType {
    
    public weak var delegate: PasscodeLockTypeDelegate?
    public let configuration: PasscodeLockConfigurationType
    
    public var repository: PasscodeRepositoryType {
        return configuration.repository
    }
    
    public var state: PasscodeLockStateType {
        return lockState
    }
    
    public var isTouchIDAllowed: Bool {
        return isTouchIDEnabled() && configuration.isTouchIDAllowed && lockState.isTouchIDAllowed
    }

	public var isPincodeEmpty: Bool {
		return passcode.isEmpty
	}
    
    private var lockState: PasscodeLockStateType
    private lazy var passcode = [String]()
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
    }
    
	public func addSign(_ sign: String, stringsToBeDisplayed: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
        passcode.append(sign)
        delegate?.passcodeLock(self, addedSignAtIndex: passcode.count - 1)
        
        if (passcode.count >= configuration.passcodeLength) {

            if var state = self.lockState as? EnterPasscodeState {
                if let currentPasscode = repository.passcode {

                    if (passcode == currentPasscode) {
                        delegate?.passcodeLockDidSucceed(self)

                    } else {

                        state.inccorectPasscodeAttempts += 1
                        if (state.inccorectPasscodeAttempts >= configuration.maximumInccorectPasscodeAttempts) {
                            state.postNotification()
                        }

                        delegate?.passcodeLockDidFail(self)
                    }
                }
            } else if var state = self.lockState as? SetPasscodeState {

                let nextState = ConfirmPasscodeState(passcode: passcode, stringsToShow: stringsToBeDisplayed, tintColor: tintColor, font: font)
                changeStateTo(nextState)

            } else if var state = self.lockState as? ChangePasscodeState {

                if let currentPasscode = repository.passcode {
                    if (passcode == currentPasscode) {
                        let nextState = SetPasscodeState(stringsToShow: stringsToBeDisplayed, tintColor: tintColor, font: font)
                        changeStateTo(nextState)

                    } else {
                        delegate?.passcodeLockDidFail(self)
                    }
                }

            } else if var state = self.lockState as? ConfirmPasscodeState {

                if (passcode == state.passcodeToConfirm) {
                    repository.savePasscode(passcode)
                    delegate?.passcodeLockDidSucceed(self)

                } else {

                    let mismatchTitle = (stringsToBeDisplayed?.passcodeLockMismatchTitle ?? localizedStringFor("PasscodeLockMismatchTitle", comment: "Passcode mismatch title"))
                    let mismatchDescription = (stringsToBeDisplayed?.passcodeLockMismatchDescription ?? localizedStringFor("PasscodeLockMismatchDescription", comment: "Passcode mismatch description"))
                    let nextState = SetPasscodeState(title: mismatchTitle, description: mismatchDescription, tintColor: tintColor, font: font)
                    changeStateTo(nextState)
                    delegate?.passcodeLockDidFail(self)
                }
            }

			self.passcode.removeAll(keepingCapacity: true)
        }
    }
    
    public func removeSign() {
        
        guard passcode.count > 0 else { return }
        
        passcode.removeLast()
        delegate?.passcodeLock(self, removedSignAtIndex: passcode.count)
    }
    
    public func changeStateTo(_ state: PasscodeLockStateType) {
        
        lockState = state
        delegate?.passcodeLockDidChangeState(self)
    }
    
	public func authenticateWithBiometrics(_ stringsToShow: StringsToBeDisplayed?) {
        
        guard isTouchIDAllowed else { return }
        
        let context = LAContext()
        let reason = (stringsToShow?.passcodeLockTouchIDReason ?? localizedStringFor("PasscodeLockTouchIDReason", comment: "TouchID authentication reason"))

        context.localizedFallbackTitle = (stringsToShow?.passcodeLockTouchIDButton ?? localizedStringFor("PasscodeLockTouchIDButton", comment: "TouchID authentication fallback button"))
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            success, error in
            
            self.handleTouchIDResult(success)
        }
    }
    
    private func handleTouchIDResult(_ success: Bool) {

        DispatchQueue.main.async(execute: {
            if success {
                
                self.delegate?.passcodeLockDidSucceed(self)
            }
        })
    }
    
    private func isTouchIDEnabled() -> Bool {
        
        let context = LAContext()
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
