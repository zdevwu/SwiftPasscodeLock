//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate {

    public enum LockState {
        case EnterPasscode
        case SetPasscode
        case ChangePasscode
        case RemovePasscode

		func getState(_ stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) -> PasscodeLockStateType {

            switch self {
			case .EnterPasscode: 	return EnterPasscodeState(stringsToShow: stringsToShow, tintColor: tintColor, font: font)
			case .SetPasscode: 		return SetPasscodeState(stringsToShow: stringsToShow, tintColor: tintColor, font: font)
			case .ChangePasscode: 	return ChangePasscodeState(stringsToShow: stringsToShow, tintColor: tintColor, font: font)
			case .RemovePasscode: 	return EnterPasscodeState(allowCancellation: true, stringsToShow: stringsToShow, tintColor: tintColor, font: font)
            }
        }
    }

	@IBOutlet public var passcodeButtons				: [PasscodeSignButton]?
    @IBOutlet public weak var titleLabel				: UILabel?
	@IBOutlet public weak var customImageView			: UIImageView?
    @IBOutlet public weak var descriptionLabel			: UILabel?
    @IBOutlet public var placeholders					: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
	@IBOutlet public weak var cancelDeleteButton		: UIButton?
    @IBOutlet public weak var touchIDButton				: UIButton?
    @IBOutlet public weak var placeholdersX				: NSLayoutConstraint?

    public var successCallback							: ((_ lock: PasscodeLockType) -> Void)?
	public var customImage 								: UIImage?
    public var dismissCompletionCallback				: (()->Void)?
    public var animateOnDismiss							: Bool
    public var notificationCenter						: NotificationCenter?
	public var stringsToShow							: StringsToBeDisplayed?
	public var closingView								: Bool = false

    internal let passcodeConfiguration					: PasscodeLockConfigurationType
    internal var passcodeLock							: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted 		= true

    private var shouldTryToAuthenticateWithBiometrics 	= true
	private var customTintColor							: UIColor?
	private var font 									: UIFont?

    // MARK: - Initializers

	public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true, stringToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

		self.stringsToShow = stringToShow
        self.animateOnDismiss = animateOnDismiss
		self.font = (font ?? UIFont.systemFont(ofSize: 16))
		self.customTintColor = (tintColor ?? UIColor(red: 0, green: 100/255, blue: 165/255, alpha: 1))
        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state, configuration: configuration)
        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(name: nibName, ofType: "nib")

        super.init(nibName: nibName, bundle: bundle)
        passcodeLock.delegate = self
        notificationCenter = NotificationCenter.default
    }

	public convenience init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

        self.init(state: state.getState(stringsToShow, tintColor: tintColor, font: font), configuration: configuration, animateOnDismiss: animateOnDismiss, stringToShow: stringsToShow, tintColor: tintColor, font: font)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        clearEvents()
    }

    // MARK: - View

    public override func viewDidLoad() {
        super.viewDidLoad()

		self.configurePasscodeButtons()
        self.updatePasscodeView()
        self.setupEvents()
    }

	private func configurePasscodeButtons() {

		self.placeholders.forEach { (passcodePlaceHolder: PasscodeSignPlaceholderView) in
			if let _customTintColor = self.customTintColor {
				passcodePlaceHolder.activeColor = _customTintColor
			}
			passcodePlaceHolder.setupView()
		}
	}

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if shouldTryToAuthenticateWithBiometrics {
            authenticateWithBiometrics()
        }
    }

    internal func updatePasscodeView() {

		self.customImageView?.image = self.customImage
        self.titleLabel?.text = passcodeLock.state.title
		self.titleLabel?.font = self.font
		self.titleLabel?.textColor = self.customTintColor
        self.descriptionLabel?.text = passcodeLock.state.description
        self.touchIDButton?.isHidden = !passcodeLock.isTouchIDAllowed
		self.touchIDButton?.setTitle((self.stringsToShow?.useTouchID ?? localizedStringFor("UseTouchId", comment: "")), for: .normal)
		self.touchIDButton?.setTitleColor(self.customTintColor, for: .normal)
		self.passcodeButtons?.forEach({ (passcodeButton: PasscodeSignButton) in
			passcodeButton.tintColor = self.customTintColor
		})

		self.cancelDeleteButtonSetup()
    }

    // MARK: - Events

    private func setupEvents() {

        notificationCenter?.addObserver(self, selector: #selector(appWillEnterForegroundHandler), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(appDidEnterBackgroundHandler), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    private func clearEvents() {

        notificationCenter?.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    @objc public func appWillEnterForegroundHandler(notification: NSNotification) {

        authenticateWithBiometrics()
    }

    @objc public func appDidEnterBackgroundHandler(notification: NSNotification) {

        shouldTryToAuthenticateWithBiometrics = false
    }

    // MARK: - Actions

    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {

        guard isPlaceholdersAnimationCompleted else {
			return
		}

        passcodeLock.addSign(sender.passcodeSign, stringsToBeDisplayed: self.stringsToShow, tintColor: customTintColor, font: font)
    }

    @IBAction func cancelButtonTap(_ sender: UIButton) {

        dismissPasscodeLock(passcodeLock)
    }

    @IBAction func deleteSignButtonTap(_ sender: UIButton) {

		if (passcodeLock.isPincodeEmpty == true && passcodeLock.state.isCancellableAction == true) {
			dismissPasscodeLock(passcodeLock)

		} else {
			passcodeLock.removeSign()
		}
    }

    @IBAction func touchIDButtonTap(_ sender: UIButton) {

        passcodeLock.authenticateWithBiometrics(self.stringsToShow)
    }

    private func authenticateWithBiometrics() {

        if (passcodeConfiguration.shouldRequestTouchIDImmediately == true && passcodeLock.isTouchIDAllowed == true) {
            passcodeLock.authenticateWithBiometrics(self.stringsToShow)
        }
    }

    internal func dismissPasscodeLock(_ lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {

        // if presented as modal
        if (presentingViewController?.presentedViewController == self) {

            dismiss(animated: animateOnDismiss, completion: { [weak self] in
                self?.dismissCompletionCallback?()
                completionHandler?()
            })

            return

        // if pushed in a navigation controller
        } else if navigationController != nil {
            navigationController?.popViewController(animated: animateOnDismiss)
        }

        dismissCompletionCallback?()
        completionHandler?()
    }

    // MARK: - Animations

    internal func animateWrongPassword() {

		self.cancelDeleteButtonSetup()
        isPlaceholdersAnimationCompleted = false

        animatePlaceholders(placeholders, toState: .Error)

        placeholdersX?.constant = -40
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()

		}, completion: { completed in
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .Inactive)
        })
    }

    internal func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {

        for placeholder in placeholders {
            placeholder.animateState(state)
        }
    }

    private func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {

        guard (index < placeholders.count && index >= 0) else {
			return
		}

        placeholders[index].animateState(state)
    }

    // MARK: - PasscodeLockDelegate

    public func passcodeLockDidSucceed(_ lock: PasscodeLockType) {

		self.cancelDeleteButtonSetup()
        animatePlaceholders(placeholders, toState: .Inactive)
        dismissPasscodeLock(lock, completionHandler: { [weak self] in
            self?.successCallback?(lock)
        })
    }

    public func passcodeLockDidFail(_ lock: PasscodeLockType) {

        animateWrongPassword()
    }

    public func passcodeLockDidChangeState(_ lock: PasscodeLockType) {

        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .Inactive)
		self.cancelDeleteButtonSetup()
    }

    public func passcodeLock(_ lock: PasscodeLockType, addedSignAtIndex index: Int) {

        animatePlacehodlerAtIndex(index, toState: .Active)
		self.cancelDeleteButtonSetup()
    }

    public func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int) {

        animatePlacehodlerAtIndex(index, toState: .Inactive)

        if (index == 0) {
            self.cancelDeleteButtonSetup()
        }
    }

	public func cancelDeleteButtonSetup() {

		let cancelButton = ((self.passcodeLock.isPincodeEmpty == true) ? (self.stringsToShow?.cancel ?? localizedStringFor("Cancel", comment: "")) : (self.stringsToShow?.delete ?? localizedStringFor("Delete", comment: "")))
		let titleForButton = ((self.passcodeLock.state.isCancellableAction == true) ? cancelButton : (self.stringsToShow?.delete ?? localizedStringFor("Delete", comment: "")))
		self.cancelDeleteButton?.setTitle(titleForButton, for: .normal)
		self.cancelDeleteButton?.setTitleColor(self.customTintColor?.withAlphaComponent(0.5), for: .disabled)
		self.cancelDeleteButton?.titleLabel?.font = self.font

		if (self.passcodeLock.isPincodeEmpty == true && self.passcodeLock.state.isCancellableAction == false) {
			self.cancelDeleteButton?.isEnabled = false
		} else {
			self.cancelDeleteButton?.isEnabled = true
		}
	}
}
