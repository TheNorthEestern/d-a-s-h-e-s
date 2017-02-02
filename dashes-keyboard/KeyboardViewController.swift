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
    var deleteButtonTimer: Timer?
    
    @IBOutlet weak var undoButton: CircularButton!
    @IBOutlet weak var deleteButton: CircularButton!
    @IBOutlet var nextKeyboardButton: UIButton!
    
    var lastWordTyped: String? {
        if let documentContext = textDocumentProxy.documentContextBeforeInput as String? {
            let length = documentContext.characters.count
            if length > 0 && (documentContext.containsAlphabets || documentContext.containsSymbols) {
                let components = documentContext.components(separatedBy: CharacterSet.alphanumerics.inverted)
                return components[components.endIndex - 1]
            }
        }
        return nil
    }
    
    @IBAction func sendText(_ sender: Any) {
        let tdp = (textDocumentProxy as UIKeyInput)
        if let originalWord = lastWordTyped, originalWord != "" {
            self.originalWord = lastWordTyped
            for _ in (lastWordTyped?.characters.indices)! {
                tdp.deleteBackward()
            }
            tdp.insertText("\(StringManipulator.dashify(originalWord)) ")
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
        textDocumentProxy.deleteBackward()
    }
}

extension KeyboardViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "IdealKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)

        view = objects[0] as? UIView
        
        undoButton.isEnabled = false
        undoButton.layer.opacity = 0.5
       
        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.deleteText))
        deleteButtonLongPressGestureRecognizer.minimumPressDuration = 0.5
        deleteButtonLongPressGestureRecognizer.numberOfTouchesRequired = 1
        deleteButtonLongPressGestureRecognizer.allowableMovement = 75
        deleteButton.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
        
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        nextKeyboardButton.setTitleColor(UIColor.black, for: [])
    }
}

