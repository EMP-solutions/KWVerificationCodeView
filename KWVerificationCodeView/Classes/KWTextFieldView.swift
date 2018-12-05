//
//  KWTextFieldView.swift
//  Pods
//
//  Created by KeepWorks on 13/01/17.
//  Copyright © 2017 KeepWorks Technologies Pvt Ltd. All rights reserved.
//

import UIKit

protocol KWTextFieldDelegate: class {
  func moveToNext(_ textFieldView: KWTextFieldView)
  func moveToPrevious(_ textFieldView: KWTextFieldView, oldCode: String)
  func didChangeCharacters()
}

@IBDesignable class KWTextFieldView: UIView {

  // MARK: - Constants
  static let maxCharactersLength = 1

  // MARK: - IBInspectables
  @IBInspectable var underlineColor: UIColor = UIColor.darkGray {
    didSet {
      underlineView.backgroundColor = underlineColor
    }
  }

  @IBInspectable var underlineSelectedColor: UIColor = UIColor.black

  @IBInspectable var textColor: UIColor = UIColor.darkText {
    didSet {
      numberTextField.textColor = textColor
    }
  }

  @IBInspectable var textSize: CGFloat = 24.0 {
    didSet {
      numberTextField.font = UIFont.systemFont(ofSize: textSize)
    }
  }

  @IBInspectable var textFont: String = "" {
    didSet {
      if let font = UIFont(name: textFont, size: textSize) {
        numberTextField.font = font
      } else {
        numberTextField.font = UIFont.systemFont(ofSize: textSize)
      }
    }
  }

  @IBInspectable var textFieldBackgroundColor: UIColor = UIColor.clear {
    didSet {
      numberTextField.backgroundColor = textFieldBackgroundColor
    }
  }

  @IBInspectable var textFieldTintColor: UIColor = UIColor.blue {
    didSet {
      numberTextField.tintColor = textFieldTintColor
    }
  }

  @IBInspectable var darkKeyboard: Bool = false {
    didSet {
      keyboardAppearance = darkKeyboard ? .dark : .light
      numberTextField.keyboardAppearance = keyboardAppearance
    }
  }

  // MARK: - IBOutlets
  @IBOutlet weak var numberTextField: UITextField!
  @IBOutlet weak private var underlineView: UIView!

  // MARK: - Variables
  private var keyboardAppearance = UIKeyboardAppearance.default
  weak var delegate: KWTextFieldDelegate?

  var code: String? {
    return numberTextField.text
  }

  // MARK: - Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    setup()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
// MARK: - Private Methods
    private func setup() {
        loadViewFromNib()
        numberTextField.delegate = self
        numberTextField.layer.borderWidth = 1;
        numberTextField.layer.cornerRadius = 5.0;
        numberTextField.layer.borderColor = UIColor(red: 173.0/255.0, green: 173.0/255.0, blue: 173.0/255.0, alpha: 1).cgColor
        numberTextField.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: numberTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(textfieldBeginEditing), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: numberTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(textfieldEndEditing), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: numberTextField)
    }
  // MARK: - Public Methods
  public func activate() {
    numberTextField.becomeFirstResponder()
    if numberTextField.text?.count == 0 {
      numberTextField.text = " "
    }
  }

  public func deactivate() {
    numberTextField.resignFirstResponder()
  }

  public func reset() {
    numberTextField.text = " "
    updateUnderline()
  }

    // MARK: - FilePrivate Methods
    dynamic fileprivate func textFieldDidChange(_ notification: Foundation.Notification) {
        if numberTextField.text?.count == 0 {
            numberTextField.text = " "
        }
    }
    
    fileprivate func updateUnderline() {
        underlineView.backgroundColor = numberTextField.text?.trim() != "" ? underlineSelectedColor : underlineColor
    }
    
    dynamic fileprivate func textfieldBeginEditing(){
        numberTextField.layer.borderWidth = 1;
        numberTextField.layer.cornerRadius = 5.0;
        numberTextField.layer.borderColor = UIColor(red: 28.0/255.0, green: 123.0/255.0, blue: 241.0/255.0, alpha: 1).cgColor
        numberTextField.layer.masksToBounds = true
    }
    dynamic fileprivate func textfieldEndEditing(){
        numberTextField.layer.borderWidth = 1;
        numberTextField.layer.cornerRadius = 5.0;
        numberTextField.layer.borderColor = UIColor(red: 173.0/255.0, green: 173.0/255.0, blue: 173.0/255.0, alpha: 1).cgColor
        //[UIColor colorWithRed:173.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:1]
        numberTextField.layer.masksToBounds = true
    }
    
    /*-(BOOL)checkStringIsNumberOrNot:(NSString*)numberStr{
     NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
     NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:numberStr];
     BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
     return stringIsValid;
     }*/
    
    func checkStringIsNumberOrNot(numberStr : String) -> Bool {
        let numberChar = CharacterSet(charactersIn: "0123456789")
        let currentChar = CharacterSet(charactersIn: numberStr)
        let isValid = numberChar.isSuperset(of: currentChar)
        return isValid
    }
}

// MARK: - UITextFieldDelegate
extension KWTextFieldView: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentString = numberTextField.text!
    let newString = currentString.replacingCharacters(in: textField.text!.range(from: range)!, with: string)
    if !(checkStringIsNumberOrNot(numberStr: string)) {
        return false
    }

    if newString.count > type(of: self).maxCharactersLength {
      delegate?.moveToNext(self)
      textField.text = string
    } else if newString.count == 0 {
      delegate?.moveToPrevious(self, oldCode: textField.text!)
      numberTextField.text = " "
    }

    delegate?.didChangeCharacters()
    updateUnderline()

    return newString.count <= type(of: self).maxCharactersLength
  }
}
