//
//  KeyboardViewController.swift
//  dashes-keyboard
//
//  Created by Kacy James on 1/22/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import UIKit
import MarqueeLabel

class KeyboardViewController: UIInputViewController {

    var customInterface : UIView!
    var originalWord: String!
    var deleteButtonTimer: Timer?
    
    @IBOutlet weak var undoButton: CircularButton!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var deleteButton: CircularButton!
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var dashifyButton: CircularButton!
    
    var lastWordTyped: String? {
        if let documentContext = textDocumentProxy.documentContextBeforeInput as String? {
            let length = documentContext.characters.count
            var components = [String]()
            if length > 0 {
                if (documentContext.containsAlphabets) {
                    components = documentContext.components(separatedBy: CharacterSet.alphanumerics.inverted)
                }
                if (documentContext.containsSymbols) {
                    components = documentContext.components(separatedBy: CharacterSet.symbols.inverted)
                }
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
    
    @IBAction func deleteText(timer: Timer) {
        textDocumentProxy.deleteBackward()
        updatePreview()
    }
}

extension KeyboardViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePreview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "IdealKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        
        view = objects[0] as? UIView
        
        configureDashifyButton()
        configureUndoButton()
        configureDeleteButton()
      
        
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        updatePreview()
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        updatePreview()
        nextKeyboardButton.setTitleColor(UIColor.black, for: [])
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if #available(iOS 9.0, *) {
                if traitCollection.forceTouchCapability == .available {
                    let force = touch.force / touch.maximumPossibleForce
                    print("\(force)")
                }
            }
        }
    }
    
    func configureDeleteButton() {
        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.deleteText))
        deleteButtonLongPressGestureRecognizer.minimumPressDuration = 0.5
        deleteButtonLongPressGestureRecognizer.numberOfTouchesRequired = 1
        deleteButtonLongPressGestureRecognizer.allowableMovement = 75
        deleteButton.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
    }
    
    func configureUndoButton() {
        undoButton.isEnabled = false
        undoButton.layer.opacity = 0.5
    }
    
    func configureDashifyButton() {
        dashifyButton.titleLabel?.numberOfLines = 1
        dashifyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dashifyButton.titleLabel?.lineBreakMode = .byClipping
    }
    
    func updatePreview() {
        if let l = lastWordTyped, !(lastWordTyped?.isEmpty)! {
            previewLabel.text = "☞ \(StringManipulator.dashify(l))"
            dashifyButton.isEnabled = true
            dashifyButton.setTitle(previewLabel.text, for: .normal)
        } else {
            dashifyButton.setTitle("pick a w-o-r-d", for: .normal)
            dashifyButton.isEnabled = false
        }
    }
}
