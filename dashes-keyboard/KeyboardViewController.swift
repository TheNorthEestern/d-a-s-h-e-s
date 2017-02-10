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
    var previousTouchXPos: CGFloat = 0.0
    
    @IBOutlet weak var forceCursorView: UIStackView!
    @IBOutlet weak var mainKeyGroup: UIStackView!
    @IBOutlet weak var undoButton: CircularButton!
    @IBOutlet weak var deleteButton: CircularButton!
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var dashifyButton: CircularButton!
    
    var lastWordTyped: String? {
        if let documentContext = textDocumentProxy.documentContextBeforeInput as String? {
            let length = documentContext.characters.count
            var components = [String]()
            if length > 0 {
                if (documentContext.containsAlphabets) {
                    components = documentContext.components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet.punctuationCharacters).inverted)
                }
                return (components.count > 0) ? components[components.endIndex - 1] : nil
            }
        }
        return nil
    }
    
    @IBAction func sendText(_ sender: Any) {
        let tdp = (textDocumentProxy as UIKeyInput)
        if let originalWord = lastWordTyped {
            self.originalWord = lastWordTyped
            for _ in (lastWordTyped?.characters.indices)! {
                tdp.deleteBackward()
            }
            tdp.insertText("\(StringManipulator.dashify(originalWord)) ")
            undoButton.layer.opacity = 1.0
            undoButton.isEnabled = true
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
        if let word = originalWord {
            if (userHasBegunDeleting(the: word)) {
                configureUndoButton()
            }
        }
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
        print("called view did appear")
        updatePreview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("called view did load")
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
            let t = touch.location(in: self.view)
            
            if #available(iOS 9.0, *) {
                if traitCollection.forceTouchCapability == .available {
                    // let force = touch.force / touch.maximumPossibleForce
                    if touch.force >= (touch.maximumPossibleForce / 2) {
                        mainKeyGroup.isHidden = true
                        forceCursorView.isHidden = false
                        let increase = t.x - previousTouchXPos
                        let percentIncrease = increase / (previousTouchXPos * 100)
                        print(percentIncrease)
                        if percentIncrease < 0 {
                            previousTouchXPos = t.x
                            Thread.sleep(forTimeInterval: 0.065)
                            textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
                        }
                        if percentIncrease > 0 {
                            previousTouchXPos = t.x
                            Thread.sleep(forTimeInterval: 0.065)
                            textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
                        }
                    } else {
                        mainKeyGroup.isHidden = false
                        forceCursorView.isHidden = true
                    }
                }
            }
        }
    }
    
    func userHasBegunDeleting(the modifiedWord: String) -> Bool {
        return StringManipulator.dashify(modifiedWord) == lastWordTyped!
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
        if let word = lastWordTyped, word.characters.count > 1 && !(word.containsPunctuation) {
                dashifyButton.isEnabled = true
                dashifyButton.setTitle("☞ \(StringManipulator.dashify(word))", for: .normal)
        } else {
            dashifyButton.setTitle("⬆︎ select a word ⬆︎", for: .normal)
            dashifyButton.isEnabled = false
            // dashifyButton.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
}
