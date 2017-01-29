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
    var originalWord: String!
    var timer: Timer?

    @IBOutlet var deleteGestureRecognizer: UILongPressGestureRecognizer!
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
    
    @IBOutlet weak var undoButton: CircularButton!
    @IBOutlet weak var deleteButton: CircularButton!
    @IBOutlet var nextKeyboardButton: UIButton!
    
    @IBAction func sendText(_ sender: Any) {
        let tdp = (textDocumentProxy as UIKeyInput)
        if let originalWord = lastWordTyped, originalWord != "" {
            self.originalWord = lastWordTyped
            for _ in (lastWordTyped?.characters.indices)! {
                textDocumentProxy.deleteBackward()
            }
            tdp.insertText("\(dashify(originalWord)) ")
            undoButton.layer.opacity = 1.0
            undoButton.isEnabled = true
        } else {
            tdp.deleteBackward()
            sendText(self)
        }
    }
    
    @IBAction func undoDashify(_ sender: Any) {
        for _ in 0..<((originalWord?.characters.count)! * 2) {
            textDocumentProxy.deleteBackward()
        }
        (textDocumentProxy as UIKeyInput).insertText("\(originalWord!)")
        undoButton.layer.opacity = 0.5
        undoButton.isEnabled = false
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
    
    @IBAction func longPressHandler(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.deleteText(_:)), userInfo: nil, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }

}

extension KeyboardViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "IdealKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        view = objects[0] as? UIView
        
        undoButton.isEnabled = false
        undoButton.layer.opacity = 0.5
       
        
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
