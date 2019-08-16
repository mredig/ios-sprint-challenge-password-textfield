//
//  PasswordField.swift
//  PasswordTextField
//
//  Created by Ben Gohlke on 6/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class PasswordField: UIControl {

	enum PasswordStrength {
		case weak
		case medium
		case stronk
	}
    
    // Public API - these properties are used to fetch the final password and strength values
	private (set) var password: String = "" {
		didSet {
			updateViews()
		}
	}
	var passwordStrength: PasswordStrength {
		return determineStrength()
	}
    
    private let standardMargin: CGFloat = 8.0
    private let textFieldContainerHeight: CGFloat = 50.0
    private let textFieldMargin: CGFloat = 15.0
    private let colorViewSize: CGSize = CGSize(width: 60.0, height: 5.0)
    
    private let labelTextColor = UIColor(hue: 233.0/360.0, saturation: 16/100.0, brightness: 41/100.0, alpha: 1)
    private let labelFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    
    private let textFieldBorderColor = UIColor(hue: 208/360.0, saturation: 80/100.0, brightness: 94/100.0, alpha: 1)
    private let bgColor = UIColor(hue: 0, saturation: 0, brightness: 97/100.0, alpha: 1)
    
    // States of the password strength indicators
    private let unusedColor = UIColor(hue: 210/360.0, saturation: 5/100.0, brightness: 86/100.0, alpha: 1)
    private let weakColor = UIColor(hue: 0/360, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let mediumColor = UIColor(hue: 39/360.0, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let strongColor = UIColor(hue: 132/360.0, saturation: 60/100.0, brightness: 75/100.0, alpha: 1)
    
    private var titleLabel: UILabel = UILabel()
    private var textField: UITextField = UITextField()
	private var textFieldContainer = UIView()
    private var showHideButton: UIButton = UIButton()
    private var weakView: UIView = UIView()
    private var mediumView: UIView = UIView()
    private var strongView: UIView = UIView()
    private var strengthDescriptionLabel: UILabel = UILabel()
    
    func setup() {
        // Lay out your subviews here
		backgroundColor = bgColor

		let stackView = UIStackView()
		stackView.alignment = .fill
		stackView.distribution = .fill
		stackView.spacing = 8
		stackView.axis = .vertical
		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.topAnchor.constraint(equalTo: topAnchor, constant: standardMargin).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standardMargin).isActive = true
		stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standardMargin).isActive = true
		stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true

		titleLabel.text = "Enter Password"
		titleLabel.font = labelFont
		titleLabel.textColor = labelTextColor
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(textFieldContainer)
		textFieldContainer.heightAnchor.constraint(equalToConstant: textFieldContainerHeight).isActive = true

		let textFieldStackView = UIStackView()
		textFieldContainer.addSubview(textFieldStackView)
		textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
		textFieldStackView.topAnchor.constraint(equalTo: textFieldContainer.topAnchor, constant: textFieldMargin).isActive = true
		textFieldStackView.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: -textFieldMargin).isActive = true
		textFieldStackView.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: textFieldMargin).isActive = true
		textFieldStackView.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -textFieldMargin).isActive = true
		textFieldStackView.addArrangedSubview(textField)
		textFieldStackView.addArrangedSubview(showHideButton)
		showHideButton.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
		showHideButton.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
		textFieldStackView.alignment = .fill
		textFieldStackView.distribution = .fill
		textFieldStackView.spacing = textFieldMargin

		textFieldContainer.layer.borderColor = textFieldBorderColor.cgColor
		textFieldContainer.layer.borderWidth = 3
		textFieldContainer.layer.cornerRadius = 5
		textField.isSecureTextEntry = true
		textField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
		textField.delegate = self

		showHideButton.addTarget(self, action: #selector(toggleSecureText), for: .touchUpInside)

		let stackView2 = UIStackView()
		stackView2.axis = .horizontal
		stackView2.alignment = .center
		stackView2.distribution = .fill
		stackView2.spacing = 8
		stackView.addArrangedSubview(stackView2)

		stackView2.addArrangedSubview(weakView)
		stackView2.addArrangedSubview(mediumView)
		stackView2.addArrangedSubview(strongView)
		stackView2.addArrangedSubview(strengthDescriptionLabel)
		weakView.widthAnchor.constraint(equalToConstant: colorViewSize.width).isActive = true
		weakView.heightAnchor.constraint(equalToConstant: colorViewSize.height).isActive = true
		weakView.backgroundColor = unusedColor
		mediumView.widthAnchor.constraint(equalTo: weakView.widthAnchor).isActive = true
		mediumView.heightAnchor.constraint(equalTo: weakView.heightAnchor).isActive = true
		mediumView.backgroundColor = unusedColor
		strongView.widthAnchor.constraint(equalTo: weakView.widthAnchor).isActive = true
		strongView.heightAnchor.constraint(equalTo: weakView.heightAnchor).isActive = true
		strongView.backgroundColor = unusedColor
		strengthDescriptionLabel.text = "Too weak"
		strengthDescriptionLabel.font = labelFont
		strengthDescriptionLabel.textColor = labelTextColor
		let labelHeight = "Blah!".size(withAttributes: [NSAttributedString.Key.font: labelFont])
		stackView2.heightAnchor.constraint(equalToConstant: labelHeight.height).isActive = true

		updateViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

	private func updateViews() {
		updateShowHideButton()
		updateStrengthIndicator()
	}

	private func updateShowHideButton() {
		if textField.isSecureTextEntry {
			showHideButton.setImage(#imageLiteral(resourceName: "eyes-closed"), for: .normal)
		} else {
			showHideButton.setImage(#imageLiteral(resourceName: "eyes-open"), for: .normal)
		}
	}

	private func updateStrengthIndicator() {
		let indicators = [weakView, mediumView, strongView]
		indicators.forEach { $0.backgroundColor = unusedColor }
		switch passwordStrength {
		case .weak:
			weakView.backgroundColor = weakColor
			strengthDescriptionLabel.text = "Too weak"
		case .medium:
			weakView.backgroundColor = mediumColor
			mediumView.backgroundColor = mediumColor
			strengthDescriptionLabel.text = "Could be stronker"
		case .stronk:
			indicators.forEach { $0.backgroundColor = strongColor }
			strengthDescriptionLabel.text = "Too stronk!"
		}
	}

	private func determineStrength() -> PasswordStrength {
		var score = password.count

		let specialCharacters = password.replacingOccurrences(of: ##"[a-zA-Z0-9]"##, with: "", options: .regularExpression, range: nil)
		let letters = password.replacingOccurrences(of: ##"[^A-Za-z]"##, with: "", options: .regularExpression, range: nil)
		let capitalLetters = letters.replacingOccurrences(of: ##"[^A-Z]"##, with: "", options: .regularExpression, range: nil)
		let lowerLetters = letters.replacingOccurrences(of: ##"[^a-z]"##, with: "", options: .regularExpression, range: nil)
		let numbers = password.replacingOccurrences(of: ##"[^0-9]"##, with: "", options: .regularExpression, range: nil)

		let lowerDups = lowerLetters.count - Set(lowerLetters).count
		score -= lowerDups

		let capitalDups = capitalLetters.count - Set(capitalLetters).count
		score -= capitalDups

		if !lowerLetters.isEmpty && !capitalLetters.isEmpty {
			score += 5
			if letters.count > 8 && Int(Double(letters.count) * 0.5) > (capitalDups + lowerDups) {
				score += 5
			}
		}

		let numberDups = numbers.count - Set(numbers).count
		score -= numberDups

		if !specialCharacters.isEmpty {
			let value = Int(Double(specialCharacters.count) * 0.1 + 1)
			score += min(value, 7)
		}

		switch score {
		case ...10:
			return .weak
		case 10...19:
			return .medium
		default:
			return .stronk
		}
	}
}

// MARK: - ui actions
extension PasswordField {

	@objc func toggleSecureText() {
		textField.isSecureTextEntry.toggle()
		updateViews()
	}


	@objc private func passwordChanged(_ sender: UITextField) {
		password = sender.text ?? ""
		sendActions(for: [.editingChanged, .valueChanged])
	}

	@objc private func editingDidEnd(_ sender: UITextField) {
		password = sender.text ?? ""
		sendActions(for: .editingDidEnd)
	}

	@objc private func editingDidBegin(_ sender: UITextField) {
		password = sender.text ?? ""
		sendActions(for: .editingDidBegin)
	}

	@objc private func editingDidEndOnExit(_ sender: UITextField) {
		password = sender.text ?? ""
		sendActions(for: .editingDidEndOnExit)
	}
}

extension PasswordField: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		sendActions(for: .editingDidEnd)
		textField.resignFirstResponder()
		return true
	}
}
