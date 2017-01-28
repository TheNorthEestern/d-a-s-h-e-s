//
//  KeyboardViewController.swift
//  dashes-keyboard
//
//  Created by Kacy James on 1/22/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    var customInterface : UIView!
    var lastChange: String!

    var lastWordTyped: String? {
        if let documentContext = textDocumentProxy.documentContextBeforeInput as String? {
            let length = documentContext.characters.count
            if length > 0 && documentContext.containsAlphabets {
                let components = documentContext.components(separatedBy: CharacterSet.alphanumerics.inverted)
                return components[components.endIndex - 1]
            }
        }
        return nil
    }
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    @IBAction func sendText(_ sender: Any) {
        lastChange = lastWordTyped
        for _ in (lastWordTyped?.characters.indices)! {
            textDocumentProxy.deleteBackward()
        }
        (textDocumentProxy as UIKeyInput).insertText("\(dashify(lastChange))")
    }
    
    @IBAction func undoDashify(_ sender: Any) {
        for _ in (lastWordTyped?.characters.indices)! {
            textDocumentProxy.deleteBackward()
        }
        (textDocumentProxy as UIKeyInput).insertText("\(lastChange!)")
    }
    
    @IBAction func deleteText(_ sender: Any) {
        (textDocumentProxy as UIKeyInput).deleteBackward()
    }
    
    func dashify(_ text: String,_ separator: Character = "-") -> String
    {
        var dashedText = [String]()
        for (index, char) in text.characters.enumerated() {
            dashedText.append("\(char)")
            if index != text.characters.count - 1 {
                dashedText.append("\(separator)")
            }
        }
        return dashedText.joined()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "IdealKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        view = objects[0] as? UIView
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
}

extension String {
    var containsAlphabets: Bool {
        return utf16.contains { (CharacterSet.alphanumerics as NSCharacterSet).characterIsMember($0) }
    }
}
