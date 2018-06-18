//
//  PasscodeSettingsViewController.swift
//  PasscodeLockDemo
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import PasscodeLock

class PasscodeSettingsViewController: UIViewController {
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var changePasscodeButton: UIButton!
    @IBOutlet weak var testTextField: UITextField!
    @IBOutlet weak var testActivityButton: UIButton!
    
    private let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - View
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
    }
    
    func updatePasscodeView() {
        
        let hasPasscode = configuration.repository.hasPasscode
        
        changePasscodeButton.isHidden = !hasPasscode
        passcodeSwitch.isOn = hasPasscode
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSwitchValueChange(_ sender: UISwitch) {
        
        let passcodeVC: PasscodeLockViewController
        
        if passcodeSwitch.isOn {
            
			passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration, stringsToShow: nil, tintColor: UIColor.blue, font: UIFont.italicSystemFont(ofSize: 16))

        } else {
            
			passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration, stringsToShow: nil, tintColor: UIColor.blue, font: UIFont.italicSystemFont(ofSize: 16))

            passcodeVC.successCallback = { lock in
                
                lock.repository.deletePasscode()
            }
        }
        
        present(passcodeVC, animated: true)
    }
    
    @IBAction func changePasscodeButtonTap(_ sender: UIButton) {
        
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
		let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config, stringsToShow: nil, tintColor: UIColor.blue, font: UIFont.italicSystemFont(ofSize: 16))

        present(passcodeLock, animated: true)
    }
    
    @IBAction func testAlertButtonTap(_ sender: UIButton) {
        
        let alertVC = UIAlertController(title: "Test", message: "", preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alertVC, animated: true)
        
    }
    
    @IBAction func testActivityButtonTap(_ sender: UIButton) {
        
        let activityVC = UIActivityViewController(activityItems: ["Test"], applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = testActivityButton
        activityVC.popoverPresentationController?.sourceRect = CGRect.init(x: 10, y: 20, width: 0, height: 0)
        
        present(activityVC, animated: true)
    }
    
    @IBAction func dismissKeyboard() {
        
        testTextField.resignFirstResponder()
    }
}
