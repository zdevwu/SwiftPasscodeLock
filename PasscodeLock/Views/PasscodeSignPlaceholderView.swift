//
//  PasscodeSignPlaceholderView.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

@IBDesignable
public class PasscodeSignPlaceholderView: UIView {

    public enum State {
        case Inactive
        case Active
        case Error
    }

    @IBInspectable
    public var inactiveColor: UIColor = UIColor.white {
        didSet {
            self.setupView()
        }
    }

    @IBInspectable
    public var activeColor: UIColor = UIColor.gray {
        didSet {
            self.setupView()
        }
    }

    @IBInspectable
    public var errorColor: UIColor = UIColor.red {
        didSet {
            self.setupView()
        }
    }

    public override init(frame: CGRect) {

        super.init(frame: frame)

        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 16, height: 16)
    }

    func setupView() {

        layer.cornerRadius = 7
        layer.borderWidth = 1
        layer.borderColor = activeColor.cgColor
        backgroundColor = inactiveColor
    }

    private func colorsForState(_ state: State) -> (backgroundColor: UIColor, borderColor: UIColor) {

        switch state {
        case .Inactive: return (inactiveColor, activeColor)
        case .Active: return (activeColor, activeColor)
        case .Error: return (errorColor, errorColor)
        }
    }

    public func animateState(_ state: State, completion: (() -> Void)? = nil) {

        let colors = colorsForState(state)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { [weak self] in
            self?.backgroundColor = colors.backgroundColor
            self?.layer.borderColor = colors.borderColor.cgColor

        }, completion: nil)
    }

}

